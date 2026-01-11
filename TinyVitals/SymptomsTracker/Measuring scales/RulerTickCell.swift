//
//  RulerTickCell.swift
//  HeightScreen
//
//  Created by admin0 on 1/10/26.
//

import UIKit

final class RulerTickCell: UICollectionViewCell {
    @IBOutlet weak var tickView: UIView!

    func configure(isMajor: Bool) {
        tickView.backgroundColor = isMajor ? .black : .lightGray
        tickView.constraints.first { $0.firstAttribute == .height }?.constant = isMajor ? 45 : 18
    }

}

