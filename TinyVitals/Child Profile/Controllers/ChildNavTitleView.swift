//
//  ChildNavTitleView.swift
//  ChildProfile
//
//  Created by admin0 on 12/24/25.
//

import UIKit


final class ChildNavTitleView: UIView {

    var onTap: (() -> Void)?

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let ageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private let containerView = UIView()

    private func setupUI() {

        translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        ageLabel.translatesAutoresizingMaskIntoConstraints = false

        // 🔹 Container (white pill)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 22
        containerView.clipsToBounds = true

        // 🔹 Avatar
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill

        // 🔹 Labels
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        ageLabel.font = .systemFont(ofSize: 12, weight: .regular)
        ageLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, ageLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        // Hierarchy
        addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(textStack)

        NSLayoutConstraint.activate([

            // 🔹 Container fills self
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // 🔹 Avatar
            avatarImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 36),
            avatarImageView.heightAnchor.constraint(equalToConstant: 36),

            // 🔹 Text
            textStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            // 🔹 Height
            containerView.heightAnchor.constraint(equalToConstant: 44),

            // 🔹 Minimum width (IMPORTANT)
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true

    }
    
    @objc private func handleTap() {
        onTap?()
    }



    func configure(child: ChildProfile) {
        nameLabel.text = child.name
        ageLabel.text = child.ageString()

        if let filename = child.photoFilename,
           let image = loadImage(filename) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(
                named: child.gender.lowercased() == "male"
                ? "BabyBoy"
                : "BabyGirl"
            )
        }
    }

    private func loadImage(_ filename: String) -> UIImage? {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
}
