import UIKit

class SplashViewController: UIViewController {
    
    let gradientBlock = UIView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let logoCircle = UIView()
    
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
            UIColor.systemPurple.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientBlock.layer.insertSublayer(gradientLayer, at: 0)
        view.addSubview(gradientBlock)
        
        // Logo circle (for final frame)
        logoCircle.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        logoCircle.center = CGPoint(x: view.center.x, y: view.center.y - 40) // moved closer
        logoCircle.layer.cornerRadius = 25
        logoCircle.isHidden = true
        
        let circleGradient = CAGradientLayer()
        circleGradient.frame = logoCircle.bounds
        circleGradient.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemPurple.cgColor
        ]
        circleGradient.startPoint = CGPoint(x: 0, y: 0)
        circleGradient.endPoint = CGPoint(x: 1, y: 1)
        logoCircle.layer.insertSublayer(circleGradient, at: 0)
        view.addSubview(logoCircle)
        
        // Title
        titleLabel.text = "TinyVitals"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .heavy)
        titleLabel.textColor = UIColor.purple
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "TRACK. PROTECT. GROW"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        subtitleLabel.textColor = UIColor.systemBlue.withAlphaComponent(0.7)
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40), // closer
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func startAnimationSequence() {
        // 1️⃣ Appear from bottom (faster)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.gradientBlock.center.y = self.view.center.y - 40
        }) { _ in
            // 2️⃣ Rotate + enlarge (faster)
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.gradientBlock.transform = CGAffineTransform(rotationAngle: .pi * 3/4).scaledBy(x: 1.8, y: 1.8)
            }) { _ in
                // 3️⃣ Shrink small
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
                    self.gradientBlock.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    self.gradientBlock.alpha = 0
                }) { _ in
                    self.showFinalLogo()
                }
            }
        }
    }
    
    func showFinalLogo() {
        self.gradientBlock.isHidden = true
        self.logoCircle.isHidden = false
        self.logoCircle.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.logoCircle.alpha = 1
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        })
    }
}
