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
    private let loader = UIActivityIndicatorView(style: .large)

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
        closeButton.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 17, weight: .medium))
        closeButton.tintColor = .systemPink
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 28, weight: .bold))
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Divider
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false

        // Container (card)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.label.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Text view
        textView.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 16))
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
        
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        view.addSubview(loader)

        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
        guard let type = type else { return }
        
        textView.isHidden = true
        titleLabel.isHidden = true
        divider.isHidden = true
        containerView.isHidden = true
        
        loader.startAnimating()

        let fetchType: String
        switch type {
        case .about: fetchType = "about"
        case .terms: fetchType = "terms"
        case .privacy: fetchType = "privacy"
        case .help: fetchType = "help"
        }
        
        Task {
            do {
                let content = try await ContentService.shared.fetchContent(for: fetchType)
                
                await MainActor.run {
                    self.loader.stopAnimating()
                    self.textView.isHidden = false
                    self.titleLabel.isHidden = false
                    self.divider.isHidden = false
                    self.containerView.isHidden = false
                    
                    var finalBody = content.body
                    var finalHeadings = content.headings
                    
                    if type == .about {
                        let attributions = """
                        
                        
                        Third-Party Attributions
                        
                        This application uses Lottie animations provided by LottieFiles (lottiefiles.com) and its community creators under the Lottie Simple License and CC-BY 4.0. We extend our gratitude to the following creators for their work used in this app:
                        • Heart Dementia Doctor animation
                        • Happy Boy animation
                        • Empty State & Other UI animations
                        
                        Open Source Libraries
                        • Lottie by Airbnb (Apache License 2.0)
                        • Supabase Swift Client (MIT License)
                        """
                        finalBody += attributions
                        finalHeadings.append("Third-Party Attributions")
                        finalHeadings.append("Open Source Libraries")
                    }
                    
                    self.titleLabel.text = content.title
                    self.applyStyledText(body: finalBody, headings: finalHeadings)
                }
            } catch {
                await MainActor.run {
                    self.loader.stopAnimating()
                    self.titleLabel.text = "Error"
                    self.titleLabel.isHidden = false
                    self.textView.text = "Failed to load content. Please check your connection."
                    self.textView.isHidden = false
                    self.containerView.isHidden = false
                }
//                print("Failed to fetch info content:", error)
            }
        }
    }

    
    private func applyStyledText(body: String, headings: [String]) {
        let attributed = NSMutableAttributedString(string: body)

        let bodyFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 16))
        let headingFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 19, weight: .semibold))

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
