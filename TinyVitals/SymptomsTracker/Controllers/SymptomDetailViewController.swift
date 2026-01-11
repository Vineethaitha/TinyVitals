//
//  SymptomDetailViewController.swift
//  TinyVitals
//
//  Created by user66 on 11/01/26.
//

import UIKit

final class SymptomDetailViewController: UIViewController {

    // MARK: - Data
    var entry: SymptomEntry!

    private var currentHeight: Double?
    private var currentWeight: Double?
    private var currentTemperature: Double?
    private var currentSeverity: Double?

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var heightButton: UIButton!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var temperatureButton: UIButton!
    @IBOutlet weak var severityButton: UIButton!

    @IBOutlet weak var notesTextView: UITextView!

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!

    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
        configureSheet()
    }

    private func configureSheet() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
    }

    
    private func setupUI() {

        view.backgroundColor = .systemGroupedBackground

        photoImageView.layer.cornerRadius = 12
        photoImageView.clipsToBounds = true

        notesTextView.layer.cornerRadius = 12
        notesTextView.backgroundColor = .secondarySystemBackground

        saveButton.layer.cornerRadius = 24
        saveButton.backgroundColor = .systemPink
        saveButton.setTitleColor(.white, for: .normal)
    }

    private func populateData() {

        titleLabel.text = entry.symptom.title

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: entry.date)

        currentHeight = entry.height
        currentWeight = entry.weight
        currentTemperature = entry.temperature
        currentSeverity = entry.severity

        updateButtons()

        notesTextView.text = entry.notes

        if let image = entry.image {
            photoImageView.image = image
            photoImageView.isHidden = false
        } else {
            photoImageView.isHidden = true
        }
    }

    
    private func updateButtons() {

        heightButton.setTitle(
            currentHeight != nil ? "\(currentHeight!) ft" : "Add height",
            for: .normal
        )

        weightButton.setTitle(
            currentWeight != nil ? "\(currentWeight!) kg" : "Add weight",
            for: .normal
        )

        temperatureButton.setTitle(
            currentTemperature != nil ? "\(currentTemperature!) °F" : "Add temp",
            for: .normal
        )

        severityButton.setTitle(
            currentSeverity != nil ? "Severity \(Int(currentSeverity!))" : "Add severity",
            for: .normal
        )
    }

    @IBAction func heightTapped() {
        openMeasure(.height, value: currentHeight)
    }

    @IBAction func weightTapped() {
        openMeasure(.weight, value: currentWeight)
    }

    @IBAction func temperatureTapped() {
        openMeasure(.temperature, value: currentTemperature)
    }

    @IBAction func severityTapped() {
        openMeasure(.severity, value: currentSeverity)
    }

    private func openMeasure(
        _ type: AddMeasureViewController.MeasureType,
        value: Double?
    ) {
        let vc = AddMeasureViewController(
            nibName: "AddMeasureViewController",
            bundle: nil
        )
        vc.measureType = type
        vc.selectedInitialValue = value ?? 0
        vc.delegate = self
        present(vc, animated: true)
    }

    @IBAction func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @IBAction func saveTapped() {

        entry.height = currentHeight
        entry.weight = currentWeight
        entry.temperature = currentTemperature
        entry.severity = currentSeverity
        entry.notes = notesTextView.text
        entry.image = photoImageView.image

        navigationController?.popViewController(animated: true)
    }
    
//    @IBAction func backTapped() {
//        navigationController?.popViewController(animated: true)
//    }


    
}


extension SymptomDetailViewController:
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {

        if let image =
            info[.editedImage] as? UIImage ??
            info[.originalImage] as? UIImage {

            photoImageView.image = image
            photoImageView.isHidden = false
        }

        dismiss(animated: true)
    }
}


extension SymptomDetailViewController: AddMeasureDelegate {

    func didSaveValue(
        _ value: Double,
        type: AddMeasureViewController.MeasureType
    ) {
        switch type {
        case .height:
            currentHeight = value
        case .weight:
            currentWeight = value
        case .temperature:
            currentTemperature = value
        case .severity:
            currentSeverity = value
        }

        updateButtons()
    }
}
