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

        cardView.backgroundColor = .clear
        titleLabel.textColor = .label
        if let searchText = searchText, !searchText.isEmpty {
            titleLabel.attributedText =
                highlightText(
                    fullText: vaccine.name,
                    searchText: searchText,
                    baseFont: titleLabel.font,
                    baseColor: .label
                )
        } else {
            titleLabel.text = vaccine.name
        }

        subtitleLabel.attributedText = formattedSubtitle(for: vaccine, baseFont: subtitleLabel.font, searchText: searchText)

        switch vaccine.status {
        case .completed:
            cardView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        case .skipped:
            cardView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
        case .rescheduled:
            cardView.backgroundColor = UIColor(red: 112/255, green: 210/255, blue: 237/255, alpha: 0.12)
        case .upcoming:
            cardView.backgroundColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 0.12)
        }
    }

    private func formattedSubtitle(for vaccine: VaccineItem, baseFont: UIFont, searchText: String?) -> NSAttributedString {
        let exactFormatter = DateFormatter()
        exactFormatter.dateStyle = .medium
        let exactStr = exactFormatter.string(from: vaccine.date)
        
        let statusText: String
        var statusColor = UIColor.secondaryLabel
        
        let brandPink = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        let brandBlue = UIColor(red: 112/255, green: 210/255, blue: 237/255, alpha: 1)
        
        switch vaccine.status {
        case .completed:
            statusText = "Completed"
            statusColor = UIColor { tc in tc.userInterfaceStyle == .dark ? .systemGreen : UIColor(red: 0.1, green: 0.55, blue: 0.1, alpha: 1) }
        case .skipped:
            statusText = "Skipped"
            statusColor = UIColor { tc in tc.userInterfaceStyle == .dark ? .systemRed : UIColor(red: 0.75, green: 0.1, blue: 0.1, alpha: 1) }
        case .rescheduled:
            statusText = "Rescheduled"
            statusColor = UIColor { tc in tc.userInterfaceStyle == .dark ? brandBlue : UIColor(red: 0.1, green: 0.45, blue: 0.75, alpha: 1) }
        case .upcoming:
            let cal = Calendar.current
            let now = cal.startOfDay(for: Date())
            let target = cal.startOfDay(for: vaccine.date)
            
            let components = cal.dateComponents([.day], from: now, to: target)
            guard let days = components.day else {
                statusText = "Upcoming"
                break
            }
            
            if days == 0 {
                statusText = "Today"
                statusColor = brandPink
            } else if days == 1 {
                statusText = "Tomorrow"
                statusColor = brandPink
            } else if days > 1 && days <= 60 {
                statusText = "In \(days) days"
                statusColor = .secondaryLabel
            } else if days > 60 {
                statusText = "Upcoming"
                statusColor = .secondaryLabel
            } else {
                statusText = "Overdue"
                statusColor = .systemRed
            }
        }
        
        let fullString = "\(statusText) • \(exactStr)"
        
        let attributed = NSMutableAttributedString(
            string: fullString,
            attributes: [
                .font: baseFont,
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        
        let statusRange = (fullString as NSString).range(of: statusText)
        if statusRange.location != NSNotFound {
            attributed.addAttributes([
                .foregroundColor: statusColor
            ], range: statusRange)
        }
        
        if let search = searchText, !search.isEmpty {
            let searchRange = (fullString as NSString).range(of: search, options: .caseInsensitive)
            if searchRange.location != NSNotFound {
                attributed.addAttributes([
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: baseFont.pointSize, weight: .black)
                ], range: searchRange)
            }
        }
        
        return attributed
    }

    private func highlightText(
        fullText: String,
        searchText: String,
        baseFont: UIFont,
        baseColor: UIColor
    ) -> NSAttributedString {

        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: baseFont,
                .foregroundColor: baseColor
            ]
        )

        let range = (fullText as NSString)
            .range(of: searchText, options: .caseInsensitive)

        if range.location != NSNotFound {
            attributed.addAttributes(
                [
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.boldSystemFont(ofSize: baseFont.pointSize)
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
