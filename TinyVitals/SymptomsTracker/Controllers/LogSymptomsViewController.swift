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
    @IBOutlet weak var addHeightButton: UIButton!
    @IBOutlet weak var addWeightButton: UIButton!
    @IBOutlet weak var addTemperatureButton: UIButton!
    
    @IBOutlet weak var addSeverityButton: UIButton!

    
    private var currentWeight: Double = 1.5
    private var currentHeight: Double = 1.5
    private var currentTemperature: Double = 98.6
    private var currentSeverity: Double = 5

    // Notes
    @IBOutlet weak var notesTextView: UITextView!

    // Photo
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!

    // Save
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Data
//    private var selectedSymptoms: [String] = []
    private var selectedSymptoms: [SymptomItem] = []
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
//        view.backgroundColor = .systemBackground

        // Date label
//        dateValueLabel.textColor = .systemBlue

        // Symptoms
        symptomsPreviewLabel.text = "No symptoms selected yet"
        symptomsPreviewLabel.textColor = .secondaryLabel

        // Vitals buttons
//        [heightButton, weightButton, temperatureButton].forEach {
//            $0?.layer.cornerRadius = 10
//            $0?.backgroundColor = UIColor.systemGray6
//        }

        // Notes
//        notesTextView.layer.cornerRadius = 12
//        notesTextView.layer.borderWidth = 1
//        notesTextView.layer.borderColor = UIColor.systemGray4.cgColor
//        notesTextView.text = "Add note here"
//        notesTextView.textColor = .secondaryLabel

        // Photo
        photoImageView.isHidden = true
//        photoImageView.layer.cornerRadius = 12
        photoImageView.contentMode = .scaleAspectFill
//        photoImageView.clipsToBounds = true

        // Save button
        saveButton.configuration = nil
        saveButton.layer.cornerRadius = 25
        saveButton.backgroundColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
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

//    @IBAction func selectSymptomsTapped(_ sender: UIButton) {
//        // Mock selection
//        selectedSymptoms = sampleSymptoms
//
//        symptomsPreviewLabel.textColor = .label
//        symptomsPreviewLabel.text = selectedSymptoms.joined(separator: ", ")
//    }

    @IBAction func heightTapped(_ sender: UIButton) {
//        showSampleAlert(
//            title: "Height",
//            message: "Sample Height: 120 cm"
//        ) {
//            self.addHeightButton.setTitle("120 cm", for: .normal)
//        }
        
        let vc = AddMeasureViewController(nibName: "AddMeasureViewController", bundle: nil)
        vc.measureType = .height
        vc.selectedInitialValue = currentHeight
        vc.delegate = self
        present(vc, animated: true)
    }

    @IBAction func weightTapped(_ sender: UIButton) {
//        showSampleAlert(
//            title: "Weight",
//            message: "Sample Weight: 25 kg"
//        ) {
//            self.addWeightButton.setTitle("25 kg", for: .normal)
//        }
        
        let vc = AddMeasureViewController(nibName: "AddMeasureViewController", bundle: nil)
        vc.measureType = .weight
        vc.selectedInitialValue = currentWeight
        vc.delegate = self
        present(vc, animated: true)
    }

    @IBAction func temperatureTapped(_ sender: UIButton) {
//        showSampleAlert(
//            title: "Temperature",
//            message: "Sample Temperature: 98.6°F"
//        ) {
//            self.temperatureButton.setTitle("98.6°F", for: .normal)
//        }
        let vc = AddMeasureViewController(
            nibName: "AddMeasureViewController",
            bundle: nil
        )
        vc.measureType = .temperature
        vc.selectedInitialValue = currentTemperature
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func addSeverityTapped(_ sender: UIButton) {
        let vc = AddMeasureViewController(nibName: "AddMeasureViewController", bundle: nil)
        vc.measureType = .severity
        vc.selectedInitialValue = currentSeverity
        vc.delegate = self
        present(vc, animated: true)
    }

    @IBAction func addPhotoTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
           picker.sourceType = .photoLibrary
           picker.delegate = self
           picker.allowsEditing = true
           present(picker, animated: true)
    }

    @IBAction func saveTapped(_ sender: UIButton) {
//        let alert = UIAlertController(
//            title: "Saved",
//            message: "Symptoms saved successfully (mock)",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        navigationController?.popViewController(animated: true)
//        present(alert, animated: true)
        let formatter = DateFormatter()
            formatter.timeStyle = .short

            let time = formatter.string(from: selectedDate)

        let items = selectedSymptoms.map { symptom in
            SymptomTimelineItem(
                title: symptom.title,
                description: "Reported by parent",
                time: time,
                color: symptom.tintColor,
                iconName: symptom.iconName
            )
            }

            // SAVE TO CENTRAL STORE
            SymptomsDataStore.shared.addSymptoms(
                items,
                on: selectedDate
            )

            navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func selectSymptomsTapped(_ sender: UIButton) {

        let vc = SymptomsSelectionViewController(
            nibName: "SymptomsSelectionViewController",
            bundle: nil
        )

        vc.onApply = { selected in
            self.selectedSymptoms = selected

            self.symptomsPreviewLabel.text =
                selected.map { $0.title }.joined(separator: ", ")

            self.symptomsPreviewLabel.textColor = .label
        }



        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
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
    
    private func updateButtonTitle() {
        addWeightButton.setTitle(
            String(format: "%.1f kg", currentWeight),
            for: .normal
        )

        addHeightButton.setTitle(
            String(format: "%.1f ft", currentHeight),
            for: .normal
        )

        addTemperatureButton.setTitle(
            String(format: "%.1f °F", currentTemperature),
            for: .normal
        )

        addSeverityButton.setTitle(
            "Severity \(Int(currentSeverity))",
            for: .normal
        )
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

extension LogSymptomsViewController: AddMeasureDelegate {

    func didSaveValue(_ value: Double, type: AddMeasureViewController.MeasureType) {
        switch type {
        case .weight:
            currentWeight = value
        case .height:
            currentHeight = value
        case .temperature:
            currentTemperature = value
        case .severity:
            currentSeverity = value
        }
        updateButtonTitle()
    }


}
