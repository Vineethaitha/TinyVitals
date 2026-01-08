//
//  EmptyStateAnimationView.swift
//  HomeScreen_Feat
//
//  Created by admin0 on 12/17/25.
//

import Foundation
import UIKit
import Lottie

final class EmptyStateAnimationView: UIView {

    private let animationView: LottieAnimationView
    private let action: (() -> Void)?

    init(
        animationName: String,
        message: String,
        animationSize: CGFloat = 180,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.animationView = LottieAnimationView(name: animationName)
        self.action = action
        super.init(frame: .zero)

        setupUI(
            message: message,
            animationSize: animationSize,
            actionTitle: actionTitle
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func play() {
        animationView.play()
    }

    func stop() {
        animationView.stop()
    }

    private func setupUI(
        message: String,
        animationSize: CGFloat,
        actionTitle: String?
    ) {

        // Animation
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.animationSpeed = 0.8   // slower (default is 1.0)
        animationView.play()


        // Message label
        let label = UILabel()
        label.text = message
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        addSubview(animationView)
        addSubview(label)

        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            animationView.widthAnchor.constraint(equalToConstant: animationSize),
            animationView.heightAnchor.constraint(equalToConstant: animationSize),

            label.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])

        // Optional CTA button
        if let actionTitle {
            let button = UIButton(type: .system)
            button.setTitle(actionTitle, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            button.backgroundColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 25
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addAction(UIAction { _ in self.action?() }, for: .touchUpInside)

            addSubview(button)

            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
                button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
                button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
                button.heightAnchor.constraint(equalToConstant: 50)
            ])

        }

        // ✨ bounce-in animation
        transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        alpha = 0

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.6
        ) {
            self.transform = .identity
            self.alpha = 1
        }
    }
}

