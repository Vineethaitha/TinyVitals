//
//  ArticleCardCell.swift
//  HomeScreen_Feat
//
//  Created by admin0 on 12/17/25.
//

import UIKit

final class ArticleCardCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var animationContainerView: LottieContainerView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animationContainerView.stop()
    }
    
    func configure(title: String, subtitle: String, animationName: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        animationContainerView.play(animationName: animationName)
    }

}
