//
//  VaccineDetailViewController.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 18/12/25.
//

import UIKit

class VaccineDetailViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var activeChild: ChildProfile?


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
    @IBOutlet weak var photoCardView: UIView! 
    @IBOutlet weak var photoCardHeight: NSLayoutConstraint!


    // MARK: - Status Card (Custom Radio Buttons)

    @IBOutlet weak var statusTakenRow: UIView!
    @IBOutlet weak var statusSkippedRow: UIView!
    @IBOutlet weak var statusRescheduledRow: UIView!

    @IBOutlet weak var takenRadioImageView: UIImageView!
    @IBOutlet weak var skippedRadioImageView: UIImageView!
    @IBOutlet weak var rescheduledRadioImageView: UIImageView!

    @IBOutlet weak var saveButton: UIButton!
    // MARK: - Data (Injected)

//    enum VaccinationStatus {
//        case taken
//        case skipped
//        case rescheduled
//    }

    var vaccineIndex: Int?
    var onSaveStatus: ((VaccineStatus) -> Void)?
    var onStatusUpdated: ((VaccineItem) -> Void)?


    private var selectedStatus: VaccineStatus = .completed
    
//    private var vaccineKey: String {
//        guard
//            let childId = activeChild?.id.uuidString,
//            let vaccine = vaccine
//        else {
//            return "invalid_vaccine_key"
//        }
//
//        return "\(childId)_\(vaccine.date.timeIntervalSince1970)"
//    }
    
    private var vaccineKey: String {
        guard let childId = activeChild?.id.uuidString else {
            return "invalid_vaccine_key"
        }
        return "\(childId)_\(vaccine.id)"
    }





    private let notesPlaceholder = "Enter notes..."
//    private var notesStorageKey: String {
//        "notes_\(activeChild.id.uuidString)_\(vaccine.name)"
//    }

    
    var vaccine: VaccineItem!
    
    
    private var notesStorageKey: String {
        "notes_\(vaccineKey)"
    }

    private var photoStorageKey: String {
        "photo_\(vaccineKey)"
    }

    private var detailStorageKey: String {
        "vaccine_detail_\(vaccineKey)"
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        guard activeChild != nil else {
            dismiss(animated: true)
            return
        }

        setupUI()
        populateData()
        setupStatusTaps()
        configure()
        setupNotes()
        setupPhotoUI()
        loadSavedDetails()
    }


    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        updateStatusUI()
//    }


    func configure() {
        titleLabel.text = vaccine.name
        descriptionLabel.text = vaccine.description
    }

    
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
        
        saveButton.configuration = nil
        saveButton.setTitle("Save", for: .normal)
        saveButton.layer.cornerRadius = 25
        saveButton.tintColor = .white
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        saveButton.backgroundColor = UIColor(red: 237/255, green: 112/255, blue: 157/255, alpha: 1)

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

        selectedStatus = vaccine.status
        updateStatusUI()
    }


    
    // MARK: - Actions
    @IBAction func addPhotoTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }


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
        selectedStatus = .completed
        UIView.animate(withDuration: 0.2) {
                self.updateStatusUI()
            }
    }

    @objc func skippedTapped() {
        selectedStatus = .skipped
        
        UIView.animate(withDuration: 0.2) {
                self.updateStatusUI()
            }
    }

    @objc func rescheduledTapped() {
        selectedStatus = .rescheduled
        
        UIView.animate(withDuration: 0.2) {
                self.updateStatusUI()
            }
    }


    func updateStatusUI() {
        let selected = UIImage(systemName: "largecircle.fill.circle")
        let unselected = UIImage(systemName: "circle")

        let activeColor = UIColor.systemBlue
           let inactiveColor = UIColor.systemGray3
        
        takenRadioImageView.image =
            selectedStatus == .completed ? selected : unselected
        takenRadioImageView.tintColor =
                selectedStatus == .completed ? activeColor : inactiveColor

        skippedRadioImageView.image =
            selectedStatus == .skipped ? selected : unselected
        skippedRadioImageView.tintColor =
               selectedStatus == .skipped ? activeColor : inactiveColor

        rescheduledRadioImageView.image =
            selectedStatus == .rescheduled ? selected : unselected
        rescheduledRadioImageView.tintColor =
                selectedStatus == .rescheduled ? activeColor : inactiveColor
        
        highlightRow(statusTakenRow, active: selectedStatus == .completed)
        highlightRow(statusSkippedRow, active: selectedStatus == .skipped)
        highlightRow(statusRescheduledRow, active: selectedStatus == .rescheduled)

        
    }

    
    // SET UP NOTES
    private func setupNotes() {
        notesTextView.delegate = self
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

        vaccineImageView.image = nil
        photoCardView.isHidden = true

        loadSavedPhoto()
        updateAddPhotoButtonTitle(hasImage: vaccineImageView.image != nil)
    }


    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        guard let image =
            (info[.editedImage] ?? info[.originalImage]) as? UIImage
        else { return }

        vaccineImageView.image = image
        photoCardView.isHidden = false
        updateAddPhotoButtonTitle(hasImage: true)
        savePhoto(image)

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }


       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true)
       }
    
    
//    private var photoStorageKey: String {
//        "photo_\(activeChild.id.uuidString)_\(vaccine.name)"
//    }


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
    
//    private var detailStorageKey: String {
//        "vaccine_detail_\(activeChild.id.uuidString)_\(vaccine.name)"
//    }


    
    @IBAction func saveTapped(_ sender: UIButton) {

        let calendar = Calendar.current
        let finalDate = calendar.date(
            bySettingHour: calendar.component(.hour, from: timePicker.date),
            minute: calendar.component(.minute, from: timePicker.date),
            second: 0,
            of: datePicker.date
        ) ?? datePicker.date

        let notesText =
            notesTextView.text == notesPlaceholder
            ? nil
            : notesTextView.text

        let imageData = vaccineImageView.image?
            .jpegData(compressionQuality: 0.8)

        let detail = VaccineDetailStorage(
            date: finalDate,
            notes: notesText,
            imageData: imageData
        )

        if let encoded = try? JSONEncoder().encode(detail) {
            UserDefaults.standard.set(encoded, forKey: detailStorageKey)
        }

        onSaveStatus?(selectedStatus)
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
}

