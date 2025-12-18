//
//  LottieContainerView.swift
//  HomeScreen_Feat
//
//  Created by admin0 on 12/17/25.
//

import Foundation
import UIKit
import Lottie

final class LottieContainerView: UIView {

    private var animationView: LottieAnimationView?

    func play(animationName: String, loop: Bool = true) {
        animationView?.removeFromSuperview()

        let animView = LottieAnimationView(name: animationName)
        animView.loopMode = loop ? .loop : .playOnce
        animView.contentMode = .scaleAspectFit
        animView.translatesAutoresizingMaskIntoConstraints = false
        animView.animationSpeed = 0.9

        addSubview(animView)

        NSLayoutConstraint.activate([
            animView.topAnchor.constraint(equalTo: topAnchor),
            animView.bottomAnchor.constraint(equalTo: bottomAnchor),
            animView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        animView.play()
        self.animationView = animView
    }

    func stop() {
        animationView?.stop()
    }
}
