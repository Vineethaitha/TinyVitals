//
//  SymptomTimelineCell.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 26/12/25.
//

import UIKit

class SymptomTimelineCell: UITableViewCell {
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var topLineView: UIView!
       @IBOutlet weak var bottomLineView: UIView!
       @IBOutlet weak var dotView: UIView!

       @IBOutlet weak var topLineHeight: NSLayoutConstraint!
       @IBOutlet weak var bottomLineHeight: NSLayoutConstraint!

    
//    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!


    override func awakeFromNib() {
            super.awakeFromNib()

            selectionStyle = .none

            // Card appearance
//            cardView.layer.cornerRadius = 16
//            cardView.layer.masksToBounds = true

            // Icon polish
            iconImageView.contentMode = .scaleAspectFit
        
            prepareForAnimation()
        }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        topLineHeight.constant = 0
        bottomLineHeight.constant = 0
        dotView.alpha = 0
    }


        func configure(with item: SymptomTimelineItem) {

            timeLabel.text = item.time
            titleLabel.text = item.title
            descriptionLabel.text = item.description

//            cardView.backgroundColor = item.color.withAlphaComponent(0.15)

            iconImageView.image = UIImage(systemName: item.iconName)
            iconImageView.tintColor = item.color

                animateTimeline()
        }
    
    private func prepareForAnimation() {
        topLineHeight.constant = 0
        bottomLineHeight.constant = 0

        dotView.alpha = 0
    }

    func animateTimeline() {
        layoutIfNeeded()

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                self.topLineHeight.constant = 24
                self.layoutIfNeeded()
            }
        )

        UIView.animate(
            withDuration: 0.4,
            delay: 0.2,
            options: [.curveEaseOut],
            animations: {
                self.bottomLineHeight.constant = 24
                self.layoutIfNeeded()
            }
        )

        UIView.animate(
            withDuration: 0.2,
            delay: 0.35,
            options: [.curveEaseIn],
            animations: {
                self.dotView.alpha = 1
            }
        )
    }
}
