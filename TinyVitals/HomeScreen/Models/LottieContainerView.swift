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
    private var articleImageView: UIImageView?

    func playAnimation(from urlString: String, loop: Bool = true) {
        clearMedia()
        
        guard let url = URL(string: urlString) else { return }
        
        LottieAnimation.loadedFrom(url: url, closure: { [weak self] animation in
            guard let self = self, let animation = animation else { return }
            
            let animView = LottieAnimationView(animation: animation)
            animView.loopMode = loop ? .loop : .playOnce
            animView.contentMode = .scaleAspectFit
            animView.translatesAutoresizingMaskIntoConstraints = false
            animView.animationSpeed = 0.9

            self.addSubview(animView)

            NSLayoutConstraint.activate([
                animView.topAnchor.constraint(equalTo: self.topAnchor),
                animView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                animView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                animView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            ])

            animView.play()
            self.animationView = animView
        }, animationCache: LRUAnimationCache.sharedCache)
    }

    func showImage(from urlString: String) {
        clearMedia()
        
        guard let url = URL(string: urlString) else { return }
        
        let localImageView = UIImageView()
        localImageView.contentMode = .scaleAspectFill
        localImageView.clipsToBounds = true
        localImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(localImageView)
        
        NSLayoutConstraint.activate([
            localImageView.topAnchor.constraint(equalTo: topAnchor),
            localImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            localImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            localImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        self.articleImageView = localImageView
        
        // Simple image download task
        URLSession.shared.dataTask(with: url) { [weak localImageView] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    localImageView?.image = image
                }
            }
        }.resume()
    }
    
    private func clearMedia() {
        animationView?.stop()
        animationView?.removeFromSuperview()
        animationView = nil
        
        articleImageView?.removeFromSuperview()
        articleImageView = nil
    }

    func stop() {
        animationView?.stop()
    }
}
