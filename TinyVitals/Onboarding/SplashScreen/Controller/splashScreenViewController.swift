//
//  splashScreenViewController.swift
//  sample work
//
//  Created by admin0 on 09/12/25.
//
//
//  splashScreenViewController.swift
//  sample work
//
//  Created by admin0 on 09/12/25.
//
import UIKit

class splashScreenViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.alpha = 0

        let titleText = NSMutableAttributedString()

        let tinyAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 204/255, green: 142/255, blue: 224/255, alpha: 1),
            .font: UIFont(name: "Sigmar-Regular", size: 42)!
        ]
        let vitalsAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 141/255, green: 192/255, blue: 217/255, alpha: 1),
            .font: UIFont(name: "Sigmar-Regular", size: 42)!
        ]

        titleText.append(NSAttributedString(string: "Tiny", attributes: tinyAttributes))
        titleText.append(NSAttributedString(string: "Vitals", attributes: vitalsAttributes))

        label.attributedText = titleText
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        titleLabel.center = view.center
        view.addSubview(titleLabel)
//        UIView.animate(withDuration: 0.8, animations: {
//            self.titleLabel.alpha = 1
//            self.titleLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//        }, completion: { _ in
//            self.animateLabelToTop()
//        })
        
        titleLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        titleLabel.alpha = 0

        UIView.animate(
            withDuration: 1.1,
            delay: 0,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                self.titleLabel.transform = .identity
                self.titleLabel.alpha = 1
            },
            completion: { _ in
                self.animateLabelToTop()
            }
        )
        
    }

    private func animateLabelToTop() {
        let targetY = view.safeAreaInsets.top + 120
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            self.titleLabel.transform = .identity
            self.titleLabel.frame.origin.y = targetY
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.goToLogin()
            }
        })
    }

    private func goToLogin() {
        let onboardingVC = OnboardingViewController(nibName: "OnboardingViewController", bundle: nil)
        let navController = UINavigationController(rootViewController: onboardingVC)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let window = windowScene.windows.first else { return }

        UIView.transition(with: window, duration: 0.8, options: .transitionCrossDissolve, animations: {
            window.rootViewController = navController
            window.makeKeyAndVisible()
        })
    }
}
