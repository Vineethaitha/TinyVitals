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

//            backgroundColor = .clear
//            contentView.backgroundColor = .clear

//            containerView.backgroundColor = .systemGray
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
                containerView.backgroundColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 0.15)
                titleLabel.textColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
            } else {
                containerView.backgroundColor = .systemGray5
                titleLabel.textColor = .label
            }
        }
//    func configure(with title: String, isSelected: Bool) {
//        titleLabel.text = title
//
//        if isSelected {
//            contentView.backgroundColor = .appPinkLight
//            titleLabel.textColor = .appPink
//        } else {
//            contentView.backgroundColor = UIColor.systemGray6
//            titleLabel.textColor = .secondaryLabel
//        }
//
//        contentView.layer.cornerRadius = 15
//    }

}
