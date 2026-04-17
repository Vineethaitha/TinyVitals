//
//  RecordCardCellCollectionViewCell.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/12/25.
//

import UIKit

class RecordCardCell: UICollectionViewCell {

    // MARK: - Brand Color
    private let brandPink = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)

    // MARK: - UI Elements
    let containerView = UIView()
    let imageViewThumb = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.backgroundColor = .clear

        // ── Container (transparent, no card) ──
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        contentView.addSubview(containerView)

        // ── Folder Icon ──
        let folderConfig = UIImage.SymbolConfiguration(pointSize: 72, weight: .regular)
        imageViewThumb.image = UIImage(systemName: "folder.fill", withConfiguration: folderConfig)
        imageViewThumb.tintColor = brandPink
        imageViewThumb.contentMode = .scaleAspectFit
        imageViewThumb.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageViewThumb)

        // ── Title Label ──
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // ── Subtitle Label (file count) ──
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

        // ── Layout ──
        NSLayoutConstraint.activate([
            // Container fills the cell
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // Folder icon — centered in upper area
            imageViewThumb.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            imageViewThumb.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageViewThumb.widthAnchor.constraint(equalToConstant: 80),
            imageViewThumb.heightAnchor.constraint(equalToConstant: 68),

            // Title below icon
            titleLabel.topAnchor.constraint(equalTo: imageViewThumb.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),

            // Subtitle below title
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),
        ])
    }

    // MARK: - Highlight / Selection Feedback

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, delay: 0,
                           options: [.curveEaseInOut, .allowUserInteraction]) {
                self.containerView.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                    : .identity
                self.containerView.alpha = self.isHighlighted ? 0.85 : 1.0
            }
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        let folderConfig = UIImage.SymbolConfiguration(pointSize: 54, weight: .regular)
        imageViewThumb.image = UIImage(systemName: "folder.fill", withConfiguration: folderConfig)
        imageViewThumb.tintColor = brandPink
        titleLabel.text = nil
        subtitleLabel.text = nil
        containerView.transform = .identity
        containerView.alpha = 1.0
    }

    // MARK: - Configure

    func configure(with folder: RecordFolder, fileCount: Int) {
        titleLabel.text = folder.name

        if fileCount == 0 {
            subtitleLabel.text = "No items"
        } else if fileCount == 1 {
            subtitleLabel.text = "1 item"
        } else {
            subtitleLabel.text = "\(fileCount) items"
        }

        // Always use the large config for crisp rendering
        let folderConfig = UIImage.SymbolConfiguration(pointSize: 54, weight: .regular)
        imageViewThumb.image = UIImage(systemName: "folder.fill", withConfiguration: folderConfig)
        imageViewThumb.tintColor = brandPink
    }

    func loadThumbnail(file: MedicalFile) {
        guard file.fileType == "image" else {
            let config = UIImage.SymbolConfiguration(pointSize: 54, weight: .regular)
            imageViewThumb.image = UIImage(systemName: "folder.fill", withConfiguration: config)
            return
        }

        imageViewThumb.image = UIImage(systemName: "photo")

        Task { @MainActor in
            do {
                let signedURL = try await MedicalRecordService.shared
                    .getSignedFileURL(path: file.filePath)

                let (data, _) = try await URLSession.shared.data(from: signedURL)

                guard let image = UIImage(data: data) else { return }

                self.imageViewThumb.image = image

            } catch {
//                print("❌ Thumbnail load failed:", error)
            }
        }
    }
}
