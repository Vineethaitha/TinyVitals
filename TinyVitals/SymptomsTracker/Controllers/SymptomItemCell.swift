//
//  SymptomItemCell.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 30/12/25.
//

import UIKit

final class SymptomItemCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    override var isSelected: Bool {
        didSet {
            updateSelection()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .systemGray6
        
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true
//                containerView.backgroundColor = .systemGray6
    }

    func configure(with item: SymptomItem, selected: Bool) {
        titleLabel.text = item.title
        iconImageView.image = UIImage(systemName: item.iconName)

        if selected {
            // ✅ Selected style
            contentView.backgroundColor = UIColor.systemPink.withAlphaComponent(0.18)
            titleLabel.textColor = .systemPink
            iconImageView.tintColor = .systemPink
        } else {
            // ✅ Unselected style (soft grey)
            contentView.backgroundColor = UIColor.systemGray5
            titleLabel.textColor = .label
            iconImageView.tintColor = item.tintColor
        }
    }



    private func updateSelection() {
        contentView.backgroundColor = isSelected
            ? UIColor.systemPink.withAlphaComponent(0.15)
            : UIColor.systemGray6
    }
}

