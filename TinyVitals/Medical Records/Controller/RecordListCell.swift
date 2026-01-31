//
//  RecordListCell.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/12/25.
//

import UIKit

class RecordListCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var aiButton: UIButton!

    var onSummaryTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    @IBAction func aiButtonTapped(_ sender: UIButton) {
        onSummaryTap?()
    }
    
    func configure(with record: MedicalFile) {
        titleLabel.text = record.title
        hospitalLabel.text = record.hospital
        dateLabel.text = "Visited \(record.date.toString())"

        thumbnailView.image = UIImage(systemName: "doc") // placeholder

        // If thumbnail already exists (local cache)
        if let image = record.thumbnail {
            thumbnailView.image = image
            return
        }

        // Otherwise load from Supabase
        Task {
            do {
                let signedURL = try await MedicalRecordService.shared
                    .getSignedFileURL(path: record.filePath)

                if record.fileType == "image" {
                    let image = try await MedicalRecordService.shared
                        .downloadImage(from: signedURL)

                    DispatchQueue.main.async {
                        self.thumbnailView.image = image
                    }
                } else {
                    // PDF thumbnail
                    let fileURL = try await MedicalRecordService.shared
                        .downloadFile(from: signedURL)

                    let image = self.generatePDFThumbnail(url: fileURL)

                    DispatchQueue.main.async {
                        self.thumbnailView.image = image
                    }
                }

            } catch {
                print("❌ Thumbnail load failed:", error)
            }
        }
    }
    
    
    private func generatePDFThumbnail(url: URL) -> UIImage? {
        guard let pdf = CGPDFDocument(url as CFURL),
              let page = pdf.page(at: 1) else { return nil }

        let rect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: rect.size)

        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(rect)
            ctx.cgContext.drawPDFPage(page)
        }
    }



}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self)
    }
}

