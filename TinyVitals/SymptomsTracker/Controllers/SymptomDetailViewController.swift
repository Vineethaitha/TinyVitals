//
//  SymptomDetailViewController.swift
//  TinyVitals
//
//  Created by user66 on 11/01/26.
//

import UIKit

final class SymptomDetailViewController: UIViewController {

    var entry: SymptomEntry!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var severityLabel: UILabel!

    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheet()
        populate()
    }

    private func setupSheet() {
        view.backgroundColor = .systemGroupedBackground
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }

    private func populate() {
        titleLabel.text = entry.symptom.title

        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        dateLabel.text = f.string(from: entry.date)

        heightLabel.text = entry.height != nil ? "\(entry.height!) ft" : "—"
        weightLabel.text = entry.weight != nil ? "\(entry.weight!) kg" : "—"
        temperatureLabel.text = entry.temperature != nil ? "\(entry.temperature!) °F" : "—"
        severityLabel.text = entry.severity != nil ? "\(Int(entry.severity!))" : "—"

        notesLabel.text = entry.notes?.isEmpty == false ? entry.notes : "No notes"

        if let image = entry.image {
            photoImageView.image = image
            photoImageView.isHidden = false
        } else {
            photoImageView.isHidden = true
        }
        
        let descriptor = UIFont.systemFont(ofSize: 22, weight: .bold)
            .fontDescriptor
            .withDesign(.rounded)

        titleLabel.font = UIFont(descriptor: descriptor!, size: 24)
        dateLabel.font = UIFont(descriptor: descriptor!, size: 17)
        weightLabel.font = UIFont(descriptor: descriptor!, size: 17)
        heightLabel.font = UIFont(descriptor: descriptor!, size: 17)
        temperatureLabel.font = UIFont(descriptor: descriptor!, size: 17)
        severityLabel.font = UIFont(descriptor: descriptor!, size: 17)
    }

//    @IBAction func deleteTapped() {
//        SymptomsDataStore.shared.deleteEntry(entry)
//        dismiss(animated: true)
//    }
//
//    @IBAction func cancelTapped() {
//        dismiss(animated: true)
//    }
}
