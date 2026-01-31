//
//  RecordCardCellCollectionViewCell.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/12/25.
//

import UIKit

class RecordCardCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageViewThumb: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.06
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8

        imageViewThumb.layer.cornerRadius = 10
        imageViewThumb.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewThumb.image = UIImage(systemName: "doc")
    }

    func configure(with folder: RecordFolder, fileCount: Int) {
        titleLabel.text = folder.name

        subtitleLabel.text = (fileCount == 0) ? "No files" : "\(fileCount) files"
        imageViewThumb.image = UIImage(systemName: "doc")
        imageViewThumb.image = folder.icon
        containerView.backgroundColor = folder.color
    }


    func loadThumbnail(file: MedicalFile) {
        guard file.fileType == "image" else {
            imageViewThumb.image = UIImage(systemName: "doc")
            return
        }

        // reset image to avoid reuse bugs
        imageViewThumb.image = UIImage(systemName: "photo")

        Task { @MainActor in
            do {
                let signedURL = try await MedicalRecordService.shared
                    .getSignedFileURL(path: file.filePath)

                let (data, _) = try await URLSession.shared.data(from: signedURL)

                guard let image = UIImage(data: data) else { return }

                self.imageViewThumb.image = image

            } catch {
                print("❌ Thumbnail load failed:", error)
            }
        }
    }




}

