//
//  VaccineCell.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 16/12/25.
//

//
//import UIKit
//
//class VaccineCell: UITableViewCell {
//
//    @IBOutlet weak var cardView: UIView!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var subtitleLabel: UILabel!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        cardView.layer.cornerRadius = 20
//        cardView.clipsToBounds = true
//
//        contentView.backgroundColor = .clear
//        backgroundColor = .clear
//        selectionStyle = .none
//    }
//
//    func configure(with vaccine: Vaccine) {
//        titleLabel.text = vaccine.name
//
//        switch vaccine.status {
//        case .upcoming:
//            subtitleLabel.text = "Due at \(vaccine.ageGroup)"
//        case .completed:
//            subtitleLabel.text = "Completed"
//        case .rescheduled:
//            subtitleLabel.text = "Rescheduled"
//        }
//    }
//}

import UIKit

class VaccineCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!


//    func configure(with vaccine: VaccinationManagerViewController.VaccineItem) {
//            titleLabel.text = vaccine.name
//            subtitleLabel.text = vaccine.ageGroup
//        }
    
    func configure(with vaccine: VaccinationManagerViewController.VaccineItem,
                   highlight searchText: String?) {

        titleLabel.textColor = .label
        subtitleLabel.textColor = .secondaryLabel

        guard
            let searchText = searchText,
            !searchText.isEmpty
        else {
            titleLabel.text = vaccine.name
            subtitleLabel.text = vaccine.description
            return
        }

        titleLabel.attributedText =
            highlightText(
                fullText: vaccine.name,
                searchText: searchText
            )

        subtitleLabel.attributedText =
            highlightText(
                fullText: vaccine.description,
                searchText: searchText
            )
    }

    private func highlightText(
        fullText: String,
        searchText: String
    ) -> NSAttributedString {

        let attributed = NSMutableAttributedString(string: fullText)

        let range = (fullText as NSString)
            .range(of: searchText, options: .caseInsensitive)

        if range.location != NSNotFound {
            attributed.addAttributes(
                [
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
                ],
                range: range
            )
        }

        return attributed
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }

}
