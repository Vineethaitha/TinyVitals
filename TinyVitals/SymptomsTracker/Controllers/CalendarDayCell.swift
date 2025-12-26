//
//  CalendarDayCell.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 25/12/25.
//

import UIKit

final class CalendarDayCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private let dotLayer = CALayer()
    private let calendar = Calendar.current
    private var isToday = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureBaseUI()
    }
    
    private func configureBaseUI() {
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .clear
        
        dotLayer.backgroundColor = UIColor.systemPink.cgColor
        dotLayer.cornerRadius = 3
        dotLayer.isHidden = true
        contentView.layer.addSublayer(dotLayer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isToday = false
        dotLayer.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let dotSize: CGFloat = 6
        dotLayer.frame = CGRect(
            x: (contentView.bounds.width - dotSize) / 2,
            y: contentView.bounds.height - dotSize - 6,
            width: dotSize,
            height: dotSize
        )
    }
    
    // MARK: - Selection Handling
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - Public Configure
    func configure(
        day: String,
        date: String,
        cellDate: Date,
        hasSymptoms: Bool
    ) {
        dayLabel.text = day
        dateLabel.text = date
        
        isToday = calendar.isDateInToday(cellDate)
        dotLayer.isHidden = !hasSymptoms
        
        updateAppearance()
    }
    
    // MARK: - Appearance Logic
    private func updateAppearance() {
        
        if isToday && isSelected {
            // 🔥 Today AND Selected
            contentView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.3)
            dayLabel.textColor = .systemPink
            dateLabel.textColor = .systemPink
            dateLabel.font = .systemFont(ofSize: 16, weight: .bold)
            
        } else if isToday {
            // 🔴 Today only
            contentView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.25)
            dayLabel.textColor = .systemPink
            dateLabel.textColor = .systemPink
            dateLabel.font = .systemFont(ofSize: 16, weight: .bold)
            
        } else if isSelected {
            // 🌸 Selected (not today)
            contentView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.15)
            dayLabel.textColor = .systemPink
            dateLabel.textColor = .systemPink
            dateLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            
        } else {
            // ⚪ Normal
            contentView.backgroundColor = .clear
            dayLabel.textColor = .secondaryLabel
            dateLabel.textColor = .label
            dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        }
    }
}
