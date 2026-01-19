//
//  VaccineCell.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 16/12/25.
//

import UIKit

class VaccineCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    func configure(with vaccine: VaccineItem,
                   highlight searchText: String?) {

        titleLabel.textColor = .label
        subtitleLabel.textColor = .secondaryLabel

        if let searchText = searchText, !searchText.isEmpty {
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
        } else {
            titleLabel.text = vaccine.name
            subtitleLabel.text = vaccine.description
        }

        switch vaccine.status {
        case .completed:
            cardView.backgroundColor =
                UIColor.systemGreen.withAlphaComponent(0.15)

        case .skipped:
            cardView.backgroundColor =
                UIColor.systemRed.withAlphaComponent(0.15)

        case .rescheduled:
            cardView.backgroundColor =
                UIColor.systemBlue.withAlphaComponent(0.15)

        case .upcoming:
            cardView.backgroundColor = UIColor(red: 237/255, green: 112/255, blue: 157/255, alpha: 0.15)
        }
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
