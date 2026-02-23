//
//  InfoViewController.swift
//  ChildProfile
//
//  Created by admin0 on 12/25/25.
//

import UIKit

final class InfoViewController: UIViewController {

    enum InfoType {
        case about
        case terms
        case privacy
        case help
    }

    var type: InfoType!

    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let closeButton = UIButton(type: .system)
    private let containerView = UIView()
    private let divider = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
//        Haptics.impact(.light)
        setupUI()
        configureContent()
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground

        // Close button
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        closeButton.tintColor = .systemPink
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Divider
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false

        // Container (card)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Text view
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        textView.alwaysBounceVertical = true
        textView.showsVerticalScrollIndicator = false
        textView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(divider)
        view.addSubview(containerView)
        containerView.addSubview(textView)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            divider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            divider.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),

            containerView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }


    private func configureContent() {
        var title = ""
        var body = ""
        var headings: [String] = []

        switch type {

        case .about:
            title = "About TinyVitals"
            body =
            """
            TinyVitals – Smarter Care for Growing Kids

            TinyVitals is a modern child health tracking app designed to help parents monitor growth, symptoms, and overall well-being in one secure place.

            Parenting can feel overwhelming. TinyVitals simplifies health tracking by helping you:

            • Track weight and height growth trends
            • Log symptoms and temperature readings
            • Monitor severity and notes
            • Manage multiple child profiles
            • View growth comparisons against standard benchmarks

            Our mission is to provide clarity, confidence, and peace of mind for parents through thoughtful design and secure technology.

            TinyVitals is built with privacy, security, and simplicity at its core.

            This app is currently in beta. We appreciate your feedback as we continue improving the experience.
            """
            headings = ["TinyVitals – Smarter Care for Growing Kids"]

        case .terms:
            title = "Terms & Conditions"
            body =
            """
            By using TinyVitals, you agree to the following terms and conditions.

            Medical Disclaimer
            TinyVitals does not provide medical advice, diagnosis, or treatment. The information recorded in the app is for tracking purposes only. Always consult a qualified healthcare professional for medical decisions.

            User Responsibility
            You are responsible for the accuracy of the data you enter, including growth measurements, symptoms, and medical notes.

            Account & Data Security
            You are responsible for maintaining the confidentiality of your account and device access.

            Service Updates
            We may update features, functionality, or policies to improve the app experience. Continued use of the app implies acceptance of these updates.

            Misuse of the app may result in restricted access.
            """
            headings = [
                "Medical Disclaimer",
                "User Responsibility",
                "Account & Data Security",
                "Service Updates"
            ]

        case .privacy:
            title = "Privacy Policy"
            body =
            """
            Your child’s health information is sensitive. TinyVitals is designed with privacy as a top priority.

            Data Collection
            We collect only the information you explicitly provide, such as:
            • Child’s name and date of birth
            • Growth measurements
            • Symptom logs and notes
            • Uploaded images
            • Account email for authentication

            Data Usage
            Your data is used solely to provide core app functionality.

            Data Storage & Security
            Data is stored securely using encrypted services. We do not sell, rent, or share your data for advertising or marketing purposes.

            Third-Party Services
            TinyVitals uses secure backend services for authentication and storage but does not integrate third-party advertising or tracking systems.

            User Control
            You can edit or delete your data at any time within the app.

            Your data always belongs to you.
            """
            headings = [
                "Data Collection",
                "Data Usage",
                "Data Storage & Security",
                "Third-Party Services",
                "User Control"
            ]

        case .help:
            title = "Help & Support"
            body =
            """
            We’re here to help you get the most out of TinyVitals.

            Common Tasks
            • Add or edit a child profile
            • Update growth measurements
            • Log symptoms and temperature
            • Upload health-related images

            Tips for Best Experience
            • Update measurements regularly for accurate trends
            • Record symptoms as soon as they occur
            • Review growth charts periodically

            Support
            If you experience issues or have feature suggestions, please contact us:

            Email: tinyvitals.app@gmail.com

            We typically respond within 24–48 hours.

            TinyVitals continues to evolve based on real parent feedback.
            """
            headings = [
                "Common Tasks",
                "Tips for Best Experience",
                "Support"
            ]

        case .none:
            return
        }

        titleLabel.text = title
        applyStyledText(body: body, headings: headings)
    }

    
    private func applyStyledText(body: String, headings: [String]) {
        let attributed = NSMutableAttributedString(string: body)

        let bodyFont = UIFont.systemFont(ofSize: 16)
        let headingFont = UIFont.systemFont(ofSize: 19, weight: .semibold)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        attributed.addAttributes([
            .font: bodyFont,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: attributed.length))

        for heading in headings {
            let range = (body as NSString).range(of: heading)
            if range.location != NSNotFound {
                attributed.addAttributes([
                    .font: headingFont
                ], range: range)
            }
        }

        textView.attributedText = attributed
    }




    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
