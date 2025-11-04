import UIKit

class SplashViewController: UIViewController {
    
    let gradientBlock = UIView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startAnimationSequence()
    }
    
    func setupUI() {
        // Gradient block setup
        gradientBlock.frame = CGRect(x: view.center.x - 30, y: view.frame.height, width: 60, height: 60)
        gradientBlock.layer.cornerRadius = 15
        gradientBlock.clipsToBounds = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientBlock.bounds
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor(red: 0.75, green: 0.55, blue: 1.0, alpha: 1.0).cgColor // softer, lighter purple
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientBlock.layer.insertSublayer(gradientLayer, at: 0)
        view.addSubview(gradientBlock)
        
        // Title
        titleLabel.text = "TinyVitals"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        titleLabel.textColor = UIColor(red: 0.6, green: 0.25, blue: 0.85, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "TRACK. PROTECT. GROW"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        subtitleLabel.textColor = UIColor.systemBlue.withAlphaComponent(0.75)
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func startAnimationSequence() {
        // Step 1: Slide the block upward
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
            self.gradientBlock.center.y = self.view.center.y - 40
        }) { _ in
            // Step 2: Rotate and scale slightly
            UIView.animate(withDuration: 0.65, delay: 0.1, options: .curveEaseInOut, animations: {
                self.gradientBlock.transform = CGAffineTransform(rotationAngle: .pi * 3/4).scaledBy(x: 1.4, y: 1.4)
            }) { _ in
                // Step 3: Morph into small circle right above logo
                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
                    self.gradientBlock.layer.cornerRadius = 25
                    self.gradientBlock.transform = CGAffineTransform.identity.scaledBy(x: 0.45, y: 0.45)
                    self.gradientBlock.center.y = self.view.center.y - 30 // ends up just above the text
                }) { _ in
                    self.showFinalLogo()
                }
            }
        }
    }
    
    func showFinalLogo() {
        UIView.animate(withDuration: 0.65, delay: 0.15, options: .curveEaseInOut, animations: {
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -20)
            self.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }
}
