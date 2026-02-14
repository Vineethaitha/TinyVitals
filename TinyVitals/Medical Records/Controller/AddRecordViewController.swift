import UIKit
import Supabase
import UniformTypeIdentifiers

class AddRecordViewController: UIViewController,
                               UIDocumentPickerDelegate,
                               UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate {

    let store = RecordsStore.shared
    var activeChild: ChildProfile?
    var uploadedPath: String?

    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var clinicTextField: UITextField!
    @IBOutlet weak var uploadArea: UIView!
    @IBOutlet weak var visitDate: UIDatePicker!
    @IBOutlet weak var filePreviewImageView: UIImageView!
    @IBOutlet weak var dummyImageView: UIImageView!
    @IBOutlet weak var selectedSectionLabel: UILabel!
    @IBOutlet weak var sectionSelectionView: UIView!
    @IBOutlet weak var addButton: UIButton!

    var selectedFileURL: URL?
    var selectedThumbnail: UIImage?
    var selectedFolderName: String?
    var availableFolders: [String] = []

    var isEditingRecord = false
    var existingRecord: MedicalFile?
    var onRecordSaved: (() -> Void)?
    
    private let loader = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Record"

        addButton.configuration = nil
        addButton.layer.cornerRadius = addButton.frame.height / 2
        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)

        uploadArea.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(selectFileTapped))
        )

        sectionSelectionView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(selectFolderTapped))
        )

        view.addGestureRecognizer(
            UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        )

        if isEditingRecord, let record = existingRecord {
            titleTextField.text = record.title
            clinicTextField.text = record.hospital
            visitDate.date = record.date
            selectedFolderName = record.folderName
            selectedSectionLabel.text = record.folderName
            dummyImageView.isHidden = true
        }

        if selectedSectionLabel.text?.isEmpty ?? true {
            selectedSectionLabel.text = "Select Folder"
        }
        
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true

        view.addSubview(loader)

        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Save
    @IBAction func addButtonTapped(_ sender: UIButton) {

        guard let activeChild else { return }

        guard let title = titleTextField.text, !title.isEmpty else {
            showValidationAlert(message: "Enter title"); return
        }

        guard let clinic = clinicTextField.text, !clinic.isEmpty else {
            showValidationAlert(message: "Enter hospital name"); return
        }

        guard let folder = selectedFolderName else {
            showValidationAlert(message: "Select folder"); return
        }

        guard selectedThumbnail != nil || selectedFileURL != nil else {
            showValidationAlert(message: "Upload file"); return
        }

        // ✅ START LOADER
        view.endEditing(true)
        view.isUserInteractionEnabled = false
        loader.startAnimating()

        Task {
            do {
                let storage = SupabaseAuthService.shared.client.storage
                let childId = activeChild.id.uuidString

                // --- upload logic unchanged ---
                if let fileURL = selectedFileURL {
                    let name = UUID().uuidString + "." + fileURL.pathExtension
                    let path = "\(childId)/pdfs/\(name)"
                    let data = try Data(contentsOf: fileURL)

                    try await storage
                        .from("medical-records")
                        .upload(path: path, file: data)

                    uploadedPath = path

                } else if let image = selectedThumbnail {
                    let name = UUID().uuidString + ".jpg"
                    let path = "\(childId)/images/\(name)"
                    let data = image.jpegData(compressionQuality: 0.8)!

                    try await storage
                        .from("medical-records")
                        .upload(path: path, file: data)

                    uploadedPath = path
                }

                guard let uploadedPath else {
                    throw NSError(domain: "UploadFailed", code: 0)
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)

                let dto = MedicalRecordDTO(
                    id: UUID(),
                    child_id: activeChild.id,
                    title: title,
                    hospital: clinic,
                    visit_date: formatter.string(from: visitDate.date),
                    folder_name: folder,
                    file_path: uploadedPath,
                    file_type: selectedFileURL != nil ? "pdf" : "image",
                    created_at: nil
                )

                try await MedicalRecordService.shared.addRecord(dto)

                let file = MedicalFile(dto: dto)
                RecordsStore.shared.filesByChild[activeChild.id, default: []].append(file)

                // ✅ STOP LOADER + DISMISS
                await MainActor.run {
                    self.loader.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.onRecordSaved?()
                    self.dismiss(animated: true)
                }

            } catch {
                // ✅ STOP LOADER ON ERROR
                await MainActor.run {
                    self.loader.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                }
                print("❌ Record save failed:", error)
            }
        }
    }

    // MARK: - Folder
    @objc func selectFolderTapped() {
        let alert = UIAlertController(title: "Select Folder", message: nil, preferredStyle: .actionSheet)
        availableFolders.forEach { folder in
            alert.addAction(UIAlertAction(title: folder, style: .default) { _ in
                self.selectedFolderName = folder
                self.selectedSectionLabel.text = folder
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - File picking
    @objc func selectFileTapped() {
        let alert = UIAlertController(title: "Choose File", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in self.pickImage() })
        alert.addAction(UIAlertAction(title: "Browse Files", style: .default) { _ in self.pickDocument() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func pickImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let img = info[.originalImage] as? UIImage {
            selectedThumbnail = img
            filePreviewImageView.image = img
            dummyImageView.isHidden = true
            selectedFileURL = nil
        }
        picker.dismiss(animated: true)
    }

    func pickDocument() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = self
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedFileURL = url
        dummyImageView.isHidden = true
        filePreviewImageView.image = generatePDFThumbnail(url: url)
    }

    func generatePDFThumbnail(url: URL) -> UIImage? {
        guard let pdf = CGPDFDocument(url as CFURL),
              let page = pdf.page(at: 1) else { return nil }

        let rect = page.getBoxRect(.mediaBox)
        return UIGraphicsImageRenderer(size: rect.size).image {
            UIColor.white.set()
            $0.fill(rect)
            $0.cgContext.drawPDFPage(page)
        }
    }

    func showValidationAlert(message: String) {
        let alert = UIAlertController(title: "Missing Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
