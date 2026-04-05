//
//  MilestoneVideoPlayerViewController.swift
//  TinyVitals
//
//  Lightweight player for viewing recorded milestone memories.
//

import UIKit
import AVKit

final class MilestoneVideoPlayerViewController: UIViewController {

    // MARK: - Properties

    private let videoURL: URL
    private let milestoneName: String
    private let brandPink = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)

    /// Called when the user deletes the video from this player.
    var onDelete: (() -> Void)?

    // MARK: - UI

    private let playerVC = AVPlayerViewController()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let deleteButton = UIButton(type: .system)

    // MARK: - Init

    init(videoURL: URL, milestoneName: String) {
        self.videoURL = videoURL
        self.milestoneName = milestoneName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeader()
        setupPlayer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerVC.player?.pause()
    }

    // MARK: - Header

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        // Milestone name
        titleLabel.text = "🎬 \(milestoneName)"
        titleLabel.font = UIFontMetrics.default.scaledFont(
            for: .systemFont(ofSize: 20, weight: .bold)
        )
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        // Delete button
        let trashConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        deleteButton.setImage(
            UIImage(systemName: "trash.fill", withConfiguration: trashConfig),
            for: .normal
        )
        deleteButton.tintColor = .systemRed
        deleteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        deleteButton.layer.cornerRadius = 18
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        headerView.addSubview(deleteButton)

        // Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        doneButton.tintColor = brandPink
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        headerView.addSubview(doneButton)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),

            deleteButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -12),
            deleteButton.widthAnchor.constraint(equalToConstant: 36),
            deleteButton.heightAnchor.constraint(equalToConstant: 36),

            doneButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
        ])
    }

    // MARK: - Player

    private func setupPlayer() {
        let player = AVPlayer(url: videoURL)
        playerVC.player = player
        playerVC.videoGravity = .resizeAspectFill

        addChild(playerVC)
        view.addSubview(playerVC.view)
        playerVC.didMove(toParent: self)

        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        playerVC.view.layer.cornerRadius = 16
        playerVC.view.clipsToBounds = true

        NSLayoutConstraint.activate([
            playerVC.view.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            playerVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playerVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playerVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

        // Auto-play
        player.play()
    }

    // MARK: - Actions

    @objc private func doneTapped() {
        dismiss(animated: true)
    }

    @objc private func deleteTapped() {
        Haptics.impact(.light)

        let alert = UIAlertController(
            title: "Delete Video",
            message: "Are you sure you want to delete this milestone memory? This cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.playerVC.player?.pause()
            self?.onDelete?()
            self?.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
