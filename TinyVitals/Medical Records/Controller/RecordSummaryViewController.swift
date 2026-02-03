//
//  RecordSummaryViewController.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

import UIKit
import Lottie

final class RecordSummaryViewController: UIViewController {

    private let record: MedicalFile

    private let titleLabel = UILabel()
    private let textView = UITextView()
    private var lottieView: LottieAnimationView?

    init(record: MedicalFile) {
        self.record = record
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        generateSummary()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissSelf)
        )
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    // MARK: - Styling

    private struct SummaryStyle {
        static let headerFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        static let bodyFont = UIFont.systemFont(ofSize: 15)

        static let headerColor = UIColor.systemPurple
        static let bodyColor = UIColor.label

        static let sectionSpacing: CGFloat = 14
    }

    // MARK: - UI Setup

    private func setupUI() {

        titleLabel.text = "Summary"
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.showsVerticalScrollIndicator = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 28, right: 12)

        let animation = LottieAnimation.named("Stars")
        let loader = LottieAnimationView(animation: animation)
        loader.loopMode = .loop
        loader.contentMode = .scaleAspectFit
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.play()
        self.lottieView = loader

        view.addSubview(titleLabel)
        view.addSubview(loader)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            loader.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.widthAnchor.constraint(equalToConstant: 120),
            loader.heightAnchor.constraint(equalToConstant: 120),

//            textView.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 16),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Disclaimer

    private func disclaimerAttributedText() -> NSAttributedString {

        let title = NSAttributedString(
            string: "DISCLAIMER\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )

        let body = NSAttributedString(
            string:
            """
            This summary is automatically generated using on-device OCR and text analysis.
            It is provided for informational purposes only and may contain inaccuracies.

            • Not a medical diagnosis
            • Not a substitute for professional medical advice
            • Always consult a qualified healthcare provider
            • Verify details with original reports
            """,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.tertiaryLabel
            ]
        )

        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: "\n"))
        result.append(title)
        result.append(body)

        return result
    }

    // MARK: - Summary Generation

    private func generateSummary() {

        DispatchQueue.global(qos: .userInitiated).async {

            let text = RecordTextExtractor.extract(from: self.record)

            DispatchQueue.main.async {

                self.lottieView?.stop()
                self.lottieView?.removeFromSuperview()
                self.lottieView = nil

                guard text.count > 80 else {
                    self.textView.text =
                    """
                    This document appears to be blank or partially filled.

                    Tips:
                    • Upload filled reports
                    • PDFs work best
                    • Avoid blurry photos
                    """
                    return
                }

                let sections = RecordSummarizer.summarize(text: text)

                guard !sections.isEmpty else {
                    self.textView.text =
                    """
                    No structured medical information could be extracted.

                    Possible reasons:
                    • Form-style document
                    • Low OCR confidence
                    • Mostly tables or checkboxes

                    Tip:
                    Upload a typed or scanned PDF report.
                    """
                    return
                }

                let attributed = NSMutableAttributedString()

                for section in sections {

                    let header = NSAttributedString(
                        string: section.title.uppercased() + "\n",
                        attributes: [
                            .font: SummaryStyle.headerFont,
                            .foregroundColor: SummaryStyle.headerColor
                        ]
                    )

                    attributed.append(header)

                    for item in section.items.prefix(8) {
                        let bullet = NSAttributedString(
                            string: "• \(item)\n",
                            attributes: [
                                .font: SummaryStyle.bodyFont,
                                .foregroundColor: SummaryStyle.bodyColor
                            ]
                        )
                        attributed.append(bullet)
                    }

                    attributed.append(
                        NSAttributedString(
                            string: "\n",
                            attributes: [.font: UIFont.systemFont(ofSize: SummaryStyle.sectionSpacing)]
                        )
                    )
                }

                attributed.append(
                    NSAttributedString(
                        string: "──────────────\n\n",
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 12),
                            .foregroundColor: UIColor.separator
                        ]
                    )
                )
                attributed.append(self.disclaimerAttributedText())

                self.textView.attributedText = attributed
            }
        }
    }
}


