//
//  LogSymptomsViewController.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 30/12/25.
//

import UIKit

final class LogSymptomsViewController: UIViewController {
    
    private var selectedDate: Date = Date()

    // MARK: - Outlets
    @IBOutlet weak var mainScrollView: UIScrollView!
//    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!

    // Date & Time
//    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    // Symptoms
    @IBOutlet weak var selectedSymptomsLabel: UILabel!
    @IBOutlet weak var symptomsPreviewLabel: UILabel!

    // Vitals
    @IBOutlet weak var heightButton: UIButton!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var temperatureButton: UIButton!

    // Notes
    @IBOutlet weak var notesTextView: UITextView!

    // Photo
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!

    // Save
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Data
    private var selectedSymptoms: [String] = []
    private let sampleSymptoms = ["Fever", "Cold", "Cough"]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDatePicker()
        
        photoImageView.isHidden = true
        photoImageView.layer.cornerRadius = 12
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill

    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Date label
//        dateValueLabel.textColor = .systemBlue

        // Symptoms
        symptomsPreviewLabel.text = "No symptoms selected yet"
        symptomsPreviewLabel.textColor = .secondaryLabel

        // Vitals buttons
        [heightButton, weightButton, temperatureButton].forEach {
            $0?.layer.cornerRadius = 10
            $0?.backgroundColor = UIColor.systemGray6
        }

        // Notes
        notesTextView.layer.cornerRadius = 12
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.systemGray4.cgColor
        notesTextView.text = "Add note here"
        notesTextView.textColor = .secondaryLabel

        // Photo
        photoImageView.isHidden = true
        photoImageView.layer.cornerRadius = 12
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true

        // Save button
        saveButton.layer.cornerRadius = 14
        saveButton.backgroundColor = .systemIndigo
        saveButton.setTitleColor(.white, for: .normal)
    }

    private func setupDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .compact
        updateDateLabel()
    }

    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
//        dateValueLabel.text = formatter.string(from: datePicker.date)
    }

    // MARK: - Actions

    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }

    @IBAction func selectSymptomsTapped(_ sender: UIButton) {
        // Mock selection
        selectedSymptoms = sampleSymptoms

        symptomsPreviewLabel.textColor = .label
        symptomsPreviewLabel.text = selectedSymptoms.joined(separator: ", ")
    }

    @IBAction func heightTapped(_ sender: UIButton) {
        showSampleAlert(
            title: "Height",
            message: "Sample Height: 120 cm"
        ) {
            self.heightButton.setTitle("120 cm", for: .normal)
        }
    }

    @IBAction func weightTapped(_ sender: UIButton) {
        showSampleAlert(
            title: "Weight",
            message: "Sample Weight: 25 kg"
        ) {
            self.weightButton.setTitle("25 kg", for: .normal)
        }
    }

    @IBAction func temperatureTapped(_ sender: UIButton) {
        showSampleAlert(
            title: "Temperature",
            message: "Sample Temperature: 98.6°F"
        ) {
            self.temperatureButton.setTitle("98.6°F", for: .normal)
        }
    }

    @IBAction func addPhotoTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
           picker.sourceType = .photoLibrary
           picker.delegate = self
           picker.allowsEditing = true
           present(picker, animated: true)
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Saved",
            message: "Symptoms saved successfully (mock)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Helpers
    private func showSampleAlert(
        title: String,
        message: String,
        completion: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            ) { _ in completion() }
        )

        present(alert, animated: true)
    }
}


extension LogSymptomsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {

        if let image = info[.editedImage] as? UIImage
            ?? info[.originalImage] as? UIImage {

            photoImageView.image = image
            photoImageView.isHidden = false
        }

        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
