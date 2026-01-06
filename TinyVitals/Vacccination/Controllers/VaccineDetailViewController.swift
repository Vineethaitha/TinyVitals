//
//  VaccineDetailViewController.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 18/12/25.
//

//import UIKit
//
//class VaccineDetailViewController: UIViewController {
//
//    // MARK: - Outlets
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var dateLabel: UILabel!
//
//    // MARK: - Data
//    var vaccine: ViewController.VaccineItem!
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//        setupCloseButton()
//    }
//
//    // MARK: - UI Setup
//    private func setupCloseButton() {
//        let close = UIButton(type: .system)
//        close.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
//        close.tintColor = .secondaryLabel
//        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
//
//        close.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(close)
//
//        NSLayoutConstraint.activate([
//            close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
//            close.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            close.widthAnchor.constraint(equalToConstant: 32),
//            close.heightAnchor.constraint(equalToConstant: 32)
//        ])
//    }
//
//    @objc private func closeTapped() {
//        dismiss(animated: true)
//    }
//
//    private func configureUI() {
//        titleLabel.text = vaccine.name
//        descriptionLabel.text = "Scheduled at \(vaccine.ageGroup)"
//
//        switch vaccine.status {
//        case .upcoming:
//            descriptionLabel.textColor = .systemBlue
//        case .completed:
//            descriptionLabel.textColor = .systemGreen
//        case .rescheduled:
//            descriptionLabel.textColor = .systemOrange
//        }
//
//        if let date = vaccine.dueDate {
//            let formatter = DateFormatter()
//            formatter.dateStyle = .medium
//            dateLabel.text = formatter.string(from: date)
//        } else {
//            dateLabel.text = "Not scheduled"
//        }
//    }
//}

//
//import UIKit
//
//class VaccineDetailViewController: UIViewController {
//
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var statusLabel: UILabel!
//
//    var vaccine: VaccineItem!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        nameLabel.text = vaccine.name
//        descriptionLabel.text = vaccine.description
////        statusLabel.text = vaccine.status.rawValue.capitalized
//    }
//
//    @IBAction func closeTapped(_ sender: UIButton) {
//        dismiss(animated: true)
//    }
//}

import UIKit

class VaccineDetailViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Date & Time Card
        @IBOutlet weak var dateValueLabel: UILabel!
        @IBOutlet weak var timeValueLabel: UILabel!
    
    // MARK: - Date & Time Picker
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!

        // MARK: - Notes Card
        @IBOutlet weak var notesTextView: UITextView!

        // MARK: - Photo Card
        @IBOutlet weak var vaccineImageView: UIImageView!
        @IBOutlet weak var addPhotoButton: UIButton!
        @IBOutlet weak var photoCardView: UIView!  // the container view around image
        @IBOutlet weak var photoCardHeight: NSLayoutConstraint!


    // MARK: - Status Card (Custom Radio Buttons)

    @IBOutlet weak var statusTakenRow: UIView!
    @IBOutlet weak var statusSkippedRow: UIView!
    @IBOutlet weak var statusRescheduledRow: UIView!

    @IBOutlet weak var takenRadioImageView: UIImageView!
    @IBOutlet weak var skippedRadioImageView: UIImageView!
    @IBOutlet weak var rescheduledRadioImageView: UIImageView!

        // MARK: - Data (Injected)
//        var vaccine: VaccinationManagerViewController.VaccineItem!
    enum VaccinationStatus {
        case taken
        case skipped
        case rescheduled
    }

    var vaccineIndex: Int?
    var onSaveStatus: ((VaccinationManagerViewController.VaccineStatus) -> Void)?
    var onStatusUpdated: ((VaccinationManagerViewController.VaccineItem) -> Void)?


    private var selectedStatus: VaccinationStatus = .taken


    private let notesPlaceholder = "Enter notes..."
    private var notesStorageKey: String {
        return "notes_\(vaccine.name)"
    }

    
    var vaccine: VaccinationManagerViewController.VaccineItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateStatusUI()
        populateData()
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
            timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)

        updateDateTimeLabels()
        setupStatusTaps()
        configure()
        setupNotes()
        setupPhotoUI()
        loadSavedDetails()


    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateStatusUI()
    }


    func configure() {
        titleLabel.text = vaccine.name
        descriptionLabel.text = vaccine.description
    }

//    @IBAction func closeTapped(_ sender: Any) {
//        dismiss(animated: true)
//    }
    
    // MARK: - UI Setup
    private func setupUI() {

        // Notes styling
        notesTextView.layer.cornerRadius = 12
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.systemGray4.cgColor
        notesTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)

        // Image styling
        vaccineImageView.layer.cornerRadius = 12
        vaccineImageView.clipsToBounds = true
        vaccineImageView.backgroundColor = UIColor.systemGray5

        // Status segmented control
//        statusSegmentedControl.selectedSegmentIndex = 0

        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
    }

    // MARK: - Populate Data
    private func populateData() {
        guard let vaccine else { return }

        titleLabel.text = vaccine.name
        descriptionLabel.text = vaccine.description

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        // For now, show today as sample date/time
        let now = Date()
        dateValueLabel.text = formatter.string(from: now)
        timeValueLabel.text = formatter.string(from: now)
        
        // default
           selectedStatus = .taken
           updateStatusUI()
    }

    @objc private func dateChanged() {
        updateDateTimeLabels()
    }

    @objc private func timeChanged() {
        updateDateTimeLabels()
    }

    private func updateDateTimeLabels() {

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short

        dateValueLabel.text = dateFormatter.string(from: datePicker.date)
        timeValueLabel.text = timeFormatter.string(from: timePicker.date)
    }

    
    // MARK: - Actions
    @IBAction func addPhotoTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

//    @IBAction func statusChanged(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            print("Status: Upcoming")
//        case 1:
//            print("Status: Completed")
//        case 2:
//            print("Status: Rescheduled")
//        default:
//            break
//        }
//    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // Status tapped
    func setupStatusTaps() {
        statusTakenRow.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(takenTapped))
        )
        statusSkippedRow.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(skippedTapped))
        )
        statusRescheduledRow.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(rescheduledTapped))
        )

        statusTakenRow.isUserInteractionEnabled = true
        statusSkippedRow.isUserInteractionEnabled = true
        statusRescheduledRow.isUserInteractionEnabled = true
    }


    @objc func takenTapped() {
        selectedStatus = .taken
        UIView.animate(withDuration: 0.2) {
                self.updateStatusUI()
            }
//        updateStatusUI()
    }

    @objc func skippedTapped() {
        selectedStatus = .skipped
        
        UIView.animate(withDuration: 0.2) {
                self.updateStatusUI()
            }
//        updateStatusUI()
    }

    @objc func rescheduledTapped() {
        selectedStatus = .rescheduled
        
        UIView.animate(withDuration: 0.2) {
                self.updateStatusUI()
            }
//        updateStatusUI()
    }


    func updateStatusUI() {
        let selected = UIImage(systemName: "largecircle.fill.circle")
        let unselected = UIImage(systemName: "circle")

        let activeColor = UIColor.systemBlue
           let inactiveColor = UIColor.systemGray3
        
        takenRadioImageView.image =
            selectedStatus == .taken ? selected : unselected
        takenRadioImageView.tintColor =
                selectedStatus == .taken ? activeColor : inactiveColor

        skippedRadioImageView.image =
            selectedStatus == .skipped ? selected : unselected
        skippedRadioImageView.tintColor =
               selectedStatus == .skipped ? activeColor : inactiveColor

        rescheduledRadioImageView.image =
            selectedStatus == .rescheduled ? selected : unselected
        rescheduledRadioImageView.tintColor =
                selectedStatus == .rescheduled ? activeColor : inactiveColor
        
        highlightRow(statusTakenRow, active: selectedStatus == .taken)
        highlightRow(statusSkippedRow, active: selectedStatus == .skipped)
        highlightRow(statusRescheduledRow, active: selectedStatus == .rescheduled)

        
    }

    
    // SET UP NOTES
    
    private func setupNotes() {
        notesTextView.delegate = self
        notesTextView.layer.cornerRadius = 12
        notesTextView.clipsToBounds = true

        // Load saved notes
        if let savedNotes = UserDefaults.standard.string(forKey: notesStorageKey),
           !savedNotes.isEmpty {
            notesTextView.text = savedNotes
            notesTextView.textColor = .label
        } else {
            // Show placeholder
            notesTextView.text = notesPlaceholder
            notesTextView.textColor = .secondaryLabel
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == notesPlaceholder {
                textView.text = ""
                textView.textColor = .label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {

            let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)

            if text.isEmpty {
                textView.text = notesPlaceholder
                textView.textColor = .secondaryLabel
                UserDefaults.standard.removeObject(forKey: notesStorageKey)
            } else {
                UserDefaults.standard.set(text, forKey: notesStorageKey)
            }
        }
    
    // image adding
    
    private func setupPhotoUI() {
    vaccineImageView.contentMode = .scaleAspectFill
        vaccineImageView.clipsToBounds = true
        vaccineImageView.layer.cornerRadius = 12

        // IMPORTANT: hide container, not image only
        photoCardView.isHidden = true
        vaccineImageView.image = nil
        
        photoCardView.isHidden = true
//            photoCardHeight.constant = 0

        vaccineImageView.image = nil
        vaccineImageView.contentMode = .scaleAspectFill
        vaccineImageView.clipsToBounds = true
        vaccineImageView.layer.cornerRadius = 12

        loadSavedPhoto()
        updateAddPhotoButtonTitle(hasImage: false)

    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let image =
            (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
            print("❌ No image found")
            return
        }

        print("✅ Image assigned")

        vaccineImageView.image = image
        photoCardView.isHidden = false
        updateAddPhotoButtonTitle(hasImage: true)


        // 🔥 THIS IS THE FIX
//        photoCardHeight.constant = 200

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true)
       }
    
    
    private var photoStorageKey: String {
        return "photo_\(vaccine.name)"
    }

    private func savePhoto(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: photoStorageKey)
        }
    }

    private func loadSavedPhoto() {
        if let data = UserDefaults.standard.data(forKey: photoStorageKey),
           let image = UIImage(data: data) {
            vaccineImageView.image = image
            photoCardView.isHidden = false
        }
    }
    
    private var detailStorageKey: String {
        "vaccine_detail_\(vaccine.name)"
    }

    
    @IBAction func saveTapped(_ sender: UIButton) {
//        let newStatus: VaccinationManagerViewController.VaccineStatus
//
//            switch selectedStatus {
//            case .taken:
//                newStatus = .completed
//            case .skipped:
//                newStatus = .skipped
//            case .rescheduled:
//                newStatus = .rescheduled
//            }
//
//            // 🔥 THIS IS THE KEY LINE
//            onSaveStatus?(newStatus)
//
//            dismiss(animated: true)
        // 1️⃣ Save date + time (merge date & time picker)
            let calendar = Calendar.current
            let finalDate = calendar.date(
                bySettingHour: calendar.component(.hour, from: timePicker.date),
                minute: calendar.component(.minute, from: timePicker.date),
                second: 0,
                of: datePicker.date
            ) ?? datePicker.date

            // 2️⃣ Notes
            let notesText =
                notesTextView.text == notesPlaceholder
                ? nil
                : notesTextView.text

            // 3️⃣ Image
            let imageData = vaccineImageView.image?
                .jpegData(compressionQuality: 0.8)

            // 4️⃣ Create storage object
            let detail = VaccineDetailStorage(
                date: finalDate,
                notes: notesText,
                imageData: imageData
            )

            // 5️⃣ Save to UserDefaults
            if let encoded = try? JSONEncoder().encode(detail) {
                UserDefaults.standard.set(encoded, forKey: detailStorageKey)
            }

            // 6️⃣ Save status back to list
            let newStatus: VaccinationManagerViewController.VaccineStatus
            switch selectedStatus {
            case .taken: newStatus = .completed
            case .skipped: newStatus = .skipped
            case .rescheduled: newStatus = .rescheduled
            }

            onSaveStatus?(newStatus)
            dismiss(animated: true)
    }

    private func loadSavedDetails() {

        guard
            let data = UserDefaults.standard.data(forKey: detailStorageKey),
            let saved = try? JSONDecoder().decode(
                VaccineDetailStorage.self,
                from: data
            )
        else { return }

        // Date & Time
        datePicker.date = saved.date
        timePicker.date = saved.date
        updateDateTimeLabels()

        // Notes
        if let notes = saved.notes, !notes.isEmpty {
            notesTextView.text = notes
            notesTextView.textColor = .label
        }

        // Image
        if let imgData = saved.imageData,
           let image = UIImage(data: imgData) {
            vaccineImageView.image = image
            photoCardView.isHidden = false
            updateAddPhotoButtonTitle(hasImage: true)
        } else {
            updateAddPhotoButtonTitle(hasImage: false)
        }
    }


    func highlightRow(_ view: UIView, active: Bool) {
        view.backgroundColor = active
            ? UIColor.systemBlue.withAlphaComponent(0.12)
            : .clear

        view.layer.cornerRadius = view.bounds.height / 2
        view.layer.masksToBounds = true
    }
    
    private func updateAddPhotoButtonTitle(hasImage: Bool) {
        let title = hasImage ? "Edit / Replace Photo" : "Add Photo"
        addPhotoButton.setTitle(title, for: .normal)
    }
    
    


 // End of class
}


struct VaccineDetailStorage: Codable {
    let date: Date
    let notes: String?
    let imageData: Data?
}
