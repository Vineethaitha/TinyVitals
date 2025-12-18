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
        dateLabel.text = "Visited  \(record.date)"
        thumbnailView.image = record.thumbnail
    }
    



}

