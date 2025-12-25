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
            title = "About Us"
            body =
            """
            TinyVitals is a thoughtfully designed iOS application created to help parents manage, track, and understand their child’s health journey from birth through early childhood.

            Parenting involves juggling vaccination cards, growth charts, prescriptions, lab reports, and appointment notes across multiple hospitals and clinics. ChildProfile brings all of this information into one secure, easy-to-use place.

            Our mission is to reduce confusion, prevent missed vaccinations, and empower parents with clear insights into their child’s growth and health trends.

            Key Highlights
            • Centralized medical records for each child
            • Growth tracking with visual charts
            • Vaccination management and reminders
            • Secure storage of reports and prescriptions
            • Designed for families with multiple children

            ChildProfile is not a replacement for medical professionals. It is a companion app built to help parents stay organized, informed, and prepared.

            Built with care, privacy, and simplicity at heart.
            """
            headings = ["Key Highlights"]

        case .terms:
            title = "Terms & Conditions"
            body =
            """
            By using ChildProfile, you agree to the following terms and conditions.

            Medical Disclaimer
            The app does not provide medical diagnosis, treatment, or professional advice. All medical decisions should be made in consultation with qualified healthcare providers.

            Data Accuracy
            You are responsible for ensuring the accuracy of the information you enter, including growth data, vaccination details, and medical records.

            Usage Responsibility
            You are responsible for maintaining the confidentiality of your device and preventing unauthorized access to sensitive health information.

            Updates & Changes
            We may update features, policies, or the user interface to improve the app experience. Continued use implies acceptance of these updates.

            Any misuse of the app may result in restricted access.
            """
            headings = [
                "Medical Disclaimer",
                "Data Accuracy",
                "Usage Responsibility",
                "Updates & Changes"
            ]

        case .privacy:
            title = "Privacy Policy"
            body =
            """
            Your child’s health data is extremely sensitive, and privacy is at the core of ChildProfile.

            Data Collection
            We collect only the information you explicitly provide, such as:
            • Child’s name and date of birth
            • Growth measurements
            • Vaccination details
            • Uploaded medical records or images

            Data Storage
            All data is stored securely on your device. We do not sell, share, or use your data for advertising or analytics purposes.

            Third-Party Services
            ChildProfile does not integrate with third-party tracking or advertising platforms that collect personal health data.

            User Control
            You have full control over editing, deleting, and managing all stored information at any time.

            Your data always belongs to you.
            """
            headings = [
                "Data Collection",
                "Data Storage",
                "Third-Party Services",
                "User Control"
            ]

        case .help:
            title = "Help & Support"
            body =
            """
            We’re here to help you get the most out of ChildProfile.

            Common Tasks
            • Adding or editing a child’s profile
            • Updating growth measurements
            • Managing vaccination records
            • Uploading medical documents

            Tips for Best Experience
            • Update growth data regularly for accurate trends
            • Add vaccination details immediately after administration
            • Use profile switching when managing multiple children

            Support
            If you experience issues or have feature suggestions, feel free to reach out.

            Email: support@childprofile.app

            ChildProfile continues to evolve based on real parent feedback and needs.
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
