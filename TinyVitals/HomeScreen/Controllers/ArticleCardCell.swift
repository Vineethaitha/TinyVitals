//
//  ArticleCardCell.swift
//  HomeScreen_Feat
//
//  Created by admin0 on 12/17/25.
//

import UIKit
import Lottie

final class ArticleCardCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var animationContainerView: UIView!
    
    private var lottieAnimView: LottieAnimationView?
    private var localImageView: UIImageView?
    private var loadingIndicator: UIActivityIndicatorView?
    private var currentMediaURL: String?

    override func prepareForReuse() {
        super.prepareForReuse()
        clearMedia()
    }
    
    private func clearMedia() {
        lottieAnimView?.stop()
        lottieAnimView?.removeFromSuperview()
        lottieAnimView = nil
        
        localImageView?.removeFromSuperview()
        localImageView = nil
        
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
    }
    
    func configure(title: String, subtitle: String, mediaType: String, mediaURL: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        currentMediaURL = mediaURL
        
        clearMedia()
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        animationContainerView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: animationContainerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: animationContainerView.centerYAnchor)
        ])
        spinner.startAnimating()
        self.loadingIndicator = spinner
        
        if mediaType.lowercased() == "json" {
            if mediaURL.lowercased().hasPrefix("http") {
                let encodedString = mediaURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? mediaURL
                let finalUrlStr = URL(string: mediaURL) != nil ? mediaURL : encodedString
                guard let url = URL(string: finalUrlStr) else { return }
                
                LottieAnimation.loadedFrom(url: url) { [weak self] animation in
                    guard let self = self, self.currentMediaURL == mediaURL else { return }
                    
                    self.loadingIndicator?.stopAnimating()
                    self.loadingIndicator?.removeFromSuperview()
                    self.loadingIndicator = nil
                    
                    guard let animation = animation else { return }
                    self.displayLottie(animation)
                }
            } else {
                // Local Lottie Fallback
                self.loadingIndicator?.stopAnimating()
                self.loadingIndicator?.removeFromSuperview()
                self.loadingIndicator = nil
                
                if let animation = LottieAnimation.named(mediaURL) {
                    self.displayLottie(animation)
                }
            }
        } else {
            if mediaURL.lowercased().hasPrefix("http") {
                let encodedString = mediaURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? mediaURL
                let finalUrlStr = URL(string: mediaURL) != nil ? mediaURL : encodedString
                guard let url = URL(string: finalUrlStr) else { return }
                
                let imgView = self.createImageView()
                self.localImageView = imgView
                
                URLSession.shared.dataTask(with: url) { [weak imgView, weak self] data, _, _ in
                    DispatchQueue.main.async {
                        guard let self = self, self.currentMediaURL == mediaURL else { return }
                        
                        self.loadingIndicator?.stopAnimating()
                        self.loadingIndicator?.removeFromSuperview()
                        self.loadingIndicator = nil
                        
                        if let data = data, let image = UIImage(data: data) {
                            imgView?.image = image
                        }
                    }
                }.resume()
            } else {
                // Local Image Fallback
                self.loadingIndicator?.stopAnimating()
                self.loadingIndicator?.removeFromSuperview()
                self.loadingIndicator = nil
                
                let imgView = self.createImageView()
                self.localImageView = imgView
                imgView.image = UIImage(named: mediaURL)
            }
        }
    }
    
    private func displayLottie(_ animation: LottieAnimation) {
        let animView = LottieAnimationView(animation: animation)
        animView.loopMode = .loop
        animView.contentMode = .scaleAspectFit
        animView.translatesAutoresizingMaskIntoConstraints = false
        animView.animationSpeed = 0.9

        self.animationContainerView.addSubview(animView)

        NSLayoutConstraint.activate([
            animView.topAnchor.constraint(equalTo: self.animationContainerView.topAnchor),
            animView.bottomAnchor.constraint(equalTo: self.animationContainerView.bottomAnchor),
            animView.leadingAnchor.constraint(equalTo: self.animationContainerView.leadingAnchor),
            animView.trailingAnchor.constraint(equalTo: self.animationContainerView.trailingAnchor)
        ])

        animView.play()
        self.lottieAnimView = animView
    }

    private func createImageView() -> UIImageView {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        self.animationContainerView.addSubview(imgView)
        
        NSLayoutConstraint.activate([
            imgView.topAnchor.constraint(equalTo: self.animationContainerView.topAnchor),
            imgView.bottomAnchor.constraint(equalTo: self.animationContainerView.bottomAnchor),
            imgView.leadingAnchor.constraint(equalTo: self.animationContainerView.leadingAnchor),
            imgView.trailingAnchor.constraint(equalTo: self.animationContainerView.trailingAnchor)
        ])
        return imgView
    }
}
