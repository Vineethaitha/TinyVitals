//
//  CalendarDayCell.swift
//  TinyVitalsVaccinations
//
//  Created by user66 on 18/12/25.
//

import UIKit

class CalendarDayCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dotView: UIView!

    override func awakeFromNib() {
          super.awakeFromNib()

          contentView.layer.cornerRadius = 10
          contentView.backgroundColor = .systemGray6

          dotView.layer.cornerRadius = 3
          dotView.isHidden = true
      }

      func configure(day: Int, hasVaccine: Bool) {
          dayLabel.text = "\(day)"
          dotView.isHidden = !hasVaccine
          contentView.alpha = 1
      }

      func configureEmpty() {
          dayLabel.text = ""
          dotView.isHidden = true
          contentView.alpha = 0
      }
  }
