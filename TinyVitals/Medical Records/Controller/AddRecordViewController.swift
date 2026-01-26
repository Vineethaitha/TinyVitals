//
//  AddRecordViewController.swift
//  TinyVitals
//
//  Created by admin0 on 11/11/25.
//

import UIKit
import UniformTypeIdentifiers

class AddRecordViewController: UIViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let store = RecordsStore.shared
    var activeChild: ChildProfile?

    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var clinicTextField: UITextField!
    @IBOutlet weak var uploadArea: UIView!
    @IBOutlet weak var visitDate: UIDatePicker!
    @IBOutlet weak var filePreviewImageView: UIImageView!
    @IBOutlet weak var dummyImageView: UIImageView!
    @IBOutlet weak var selectedSectionLabel: UILabel!
    @IBOutlet weak var sectionSelectionView: UIView!
    
    var selectedFileURL: URL?
    var selectedThumbnail: UIImage?
    
    var selectedFolderName: String?
    var availableFolders: [String] = []   // will be passed from previous VC

    var isEditingRecord = false
    var existingRecord: MedicalFile?
    
    var onRecordSaved: (() -> Void)?

    
    @IBOutlet weak var addButton: UIButton!
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Record"
        addButton.configuration = nil
        addButton.layer.cornerRadius = addButton.frame.height / 2
        addButton.clipsToBounds = true
        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectFileTapped))
        uploadArea.addGestureRecognizer(tap)
        uploadArea.isUserInteractionEnabled = true
        
        let tapp = UITapGestureRecognizer(target: self, action: #selector(selectFolderTapped))
        sectionSelectionView.addGestureRecognizer(tapp)
        sectionSelectionView.isUserInteractionEnabled = true
        
        if isEditingRecord, let record = existingRecord {
            titleTextField.text = record.title
            clinicTextField.text = record.hospital
            visitDate.date = record.date.toDate()

            selectedFolderName = record.folderName
            selectedSectionLabel.text = selectedFolderName

            if let pdfURL = record.pdfURL {
                selectedFileURL = pdfURL
                filePreviewImageView.image = generatePDFThumbnail(url: pdfURL)
            } else if let thumb = record.thumbnail {
                selectedThumbnail = thumb
                filePreviewImageView.image = thumb
            }

            dummyImageView.isHidden = true
        }
        
        if selectedSectionLabel.text?.isEmpty ?? true {
            selectedSectionLabel.text = "Select Folder"
        }
        
//        let tappp = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tappp.cancelsTouchesInView = false
//        view.addGestureRecognizer(tappp)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
//        let tappp = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tappp.cancelsTouchesInView = false
//        tappp.requiresExclusiveTouchType = false
//        view.addGestureRecognizer(tappp)

        

    }
    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }

    
    @IBAction func addButtonTapped(_ sender: UIButton) {

        guard let activeChild else {
            assertionFailure("AddRecordViewController opened without activeChild")
            return
        }

        guard let title = titleTextField.text, !title.isEmpty else {
            showValidationAlert(message: "Enter title")
            return
        }

        guard let clinic = clinicTextField.text, !clinic.isEmpty else {
            showValidationAlert(message: "Enter hospital name")
            return
        }

        guard let folder = selectedFolderName else {
            showValidationAlert(message: "Select folder")
            return
        }

        guard selectedThumbnail != nil || selectedFileURL != nil else {
            showValidationAlert(message: "Upload file")
            return
        }

        let newRecord = MedicalFile(
            id: isEditingRecord ? existingRecord!.id : UUID().uuidString,
            childId: activeChild.id,
            title: title,
            hospital: clinic,
            date: visitDate.date.toString(),
            thumbnail: selectedThumbnail,
            pdfURL: selectedFileURL,
            folderName: folder
        )

        let store = RecordsStore.shared

        if isEditingRecord {
            store.filesByChild[activeChild.id]?.removeAll {
                $0.id == existingRecord!.id
            }
        }

        store.filesByChild[activeChild.id, default: []].append(newRecord)

        onRecordSaved?()
        dismiss(animated: true)
    }


    
    func showValidationAlert(message: String) {
        let alert = UIAlertController(
            title: "Missing Information",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }






    
    @objc func selectFolderTapped() {

        if availableFolders.isEmpty {
            print("No folders available!")
            return
        }

        let alert = UIAlertController(title: "Select Folder", message: nil, preferredStyle: .actionSheet)

        for folder in availableFolders {
            alert.addAction(UIAlertAction(title: folder, style: .default, handler: { _ in
                self.selectedFolderName = folder
                self.selectedSectionLabel.text = folder
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    
    @objc func selectFileTapped() {
        let alert = UIAlertController(title: "Choose File", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.pickImage()
        }))

        alert.addAction(UIAlertAction(title: "Browse Files", style: .default, handler: { _ in
            self.pickDocument()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    func pickImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let img = info[.originalImage] as? UIImage {
            selectedThumbnail = img
            filePreviewImageView.image = img
            dummyImageView.isHidden = true
            selectedFileURL = nil  // image only, no file URL
        }

        picker.dismiss(animated: true)
    }
    
    func pickDocument() {
        let types: [UTType] = [.pdf, .image]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {

        guard let url = urls.first else { return }

        selectedFileURL = url
        dummyImageView.isHidden = true

        if url.pathExtension.lowercased() == "pdf" {
            filePreviewImageView.image = generatePDFThumbnail(url: url)
        } else {
            filePreviewImageView.image = UIImage(contentsOfFile: url.path)
        }
    }
    
    func generatePDFThumbnail(url: URL) -> UIImage? {
        guard let pdf = CGPDFDocument(url as CFURL),
              let page = pdf.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)

        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            ctx.cgContext.drawPDFPage(page)
        }
    }


}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self)
    }
}

extension String {
    func toDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.date(from: self) ?? Date()
    }
}
