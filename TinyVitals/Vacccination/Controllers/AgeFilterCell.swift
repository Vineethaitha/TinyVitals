//
//  AgeFilterCell.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 17/12/25.
//

import UIKit

class AgeFilterCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
            super.awakeFromNib()

            backgroundColor = .clear
            contentView.backgroundColor = .clear

            containerView.backgroundColor = .systemGray6
            containerView.clipsToBounds = true

//            titleLabel.textAlignment = .center
//            titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        }

    override func layoutSubviews() {
        super.layoutSubviews()
        //            let radius = 19
        //
        //            if containerView.layer.cornerRadius != radius {
        //                containerView.layer.cornerRadius = radius
        //            }
            containerView.layer.cornerRadius = 15
        }

        func configure(with title: String, isSelected: Bool) {
            titleLabel.text = title

            if isSelected {
                containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
                titleLabel.textColor = .systemBlue
            } else {
                containerView.backgroundColor = .systemGray6
                titleLabel.textColor = .label
            }
        }
    }
