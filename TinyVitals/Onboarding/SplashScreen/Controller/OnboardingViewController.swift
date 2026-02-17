//
//  OnboardingViewController.swift
//  TinyVitals
//
//  Created by user45 on 07/11/25.
//

import UIKit

final class OnboardingViewController: UIViewController {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let stackView = UIStackView()
    private let continueButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: -10)

        UIView.animate(withDuration: 0.8) {
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
            self.titleLabel.transform = .identity
            self.subtitleLabel.transform = .identity
        }

        animateCards()
    }

    private func setupUI() {

        view.backgroundColor = .systemBackground

        // MARK: - Title

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center

        let titleText = NSMutableAttributedString()

        let tinyAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1),
            .font: UIFont(name: "Sigmar-Regular", size: 42) ?? UIFont.boldSystemFont(ofSize: 42)
        ]

        let vitalsAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 108/255, green: 173/255, blue: 226/255, alpha: 1),
            .font: UIFont(name: "Sigmar-Regular", size: 42) ?? UIFont.boldSystemFont(ofSize: 42)
        ]

        titleText.append(NSAttributedString(string: "Tiny", attributes: tinyAttributes))
        titleText.append(NSAttributedString(string: "Vitals", attributes: vitalsAttributes))

        titleLabel.attributedText = titleText

        // MARK: - Subtitle

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = "Track.Grow.Protect"
        subtitleLabel.font = UIFont(name: "Sigmar-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel


        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let card1 = createCard(
            icon: "cross.case.fill",
            title: "Medical Record Manager",
            subtitle: "Store and access medical records anytime."
        )

        let card2 = createCard(
            icon: "stethoscope",
            title: "Symptoms Tracker",
            subtitle: "Track symptoms and detect patterns early."
        )

        let card3 = createCard(
            icon: "syringe.fill",
            title: "Vaccination Tracker",
            subtitle: "Get reminders and track completed vaccines."
        )

        stackView.addArrangedSubview(card1)
        stackView.addArrangedSubview(card2)
        stackView.addArrangedSubview(card3)

        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor =
        UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 25
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        view.addSubview(stackView)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }

    private func createCard(icon: String, title: String, subtitle: String) -> UIView {

        let card = UIView()
        card.backgroundColor = UIColor.systemGray6
        card.layer.cornerRadius = 18
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 90).isActive = true

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor =
        UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iconView)
        card.addSubview(textStack)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        card.alpha = 0
        card.transform = CGAffineTransform(translationX: 0, y: 30)

        return card
    }

    private func animateCards() {

        let cards = stackView.arrangedSubviews

        for (index, card) in cards.enumerated() {

            card.transform = CGAffineTransform(translationX: 0, y: 80)
                .scaledBy(x: 0.92, y: 0.92)
            card.alpha = 0

            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.15
            card.layer.shadowRadius = 12
            card.layer.shadowOffset = CGSize(width: 0, height: 8)

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.35) {

                UIView.animate(
                    withDuration: 0.9,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 0.8,
                    options: [.curveEaseOut],
                    animations: {

                        card.alpha = 1
                        card.transform = .identity

                    },
                    completion: { _ in
                        
                        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [
                            .light,
                            .medium,
                            .heavy
                        ]
                        
                        let style = styles[index % styles.count]
                        
                        let generator = UIImpactFeedbackGenerator(style: style)
                        generator.prepare()
                        generator.impactOccurred()
                    }

                )
            }
        }
    }



    @objc private func continueTapped() {
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        navigationController?.pushViewController(loginVC, animated: true)
    }
}

