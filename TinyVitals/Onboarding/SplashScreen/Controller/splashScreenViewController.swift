//
//  splashScreenViewController.swift
//  sample work
//
//  Created by admin0 on 09/12/25.


import UIKit
import Lottie

class splashScreenViewController: UIViewController {

    // MARK: - Title Label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.alpha = 0

        let titleText = NSMutableAttributedString()

        let tinyAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1),
            .font: UIFont(name: "Sigmar-Regular", size: 42)!
        ]

        let vitalsAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 108/255, green: 173/255, blue: 226/255, alpha: 1),
            .font: UIFont(name: "Sigmar-Regular", size: 42)!
        ]

        titleText.append(NSAttributedString(string: "Tiny", attributes: tinyAttributes))
        titleText.append(NSAttributedString(string: "Vitals", attributes: vitalsAttributes))

        label.attributedText = titleText
        return label
    }()

    // MARK: - Lottie Animation
    private let lottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "Heart Dementia Doctor")
        view.contentMode = .scaleAspectFit
        view.loopMode = .playOnce
        view.animationSpeed = 1
        view.alpha = 0
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupViews()
        playSplashAnimation()
    }

    // MARK: - Setup
    private func setupViews() {

        // Lottie
        lottieView.frame = CGRect(x: 0, y: 0, width: 180, height: 180)
        lottieView.center = CGPoint(
            x: view.center.x,
            y: view.center.y - 120
        )
        view.addSubview(lottieView)

        // Title
        titleLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        titleLabel.center = view.center
        view.addSubview(titleLabel)
    }

    // MARK: - Animations
    private func playSplashAnimation() {

        // Play lottie
        lottieView.alpha = 1
        lottieView.play()

        // Prepare title
        titleLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        titleLabel.alpha = 0

        UIView.animate(
            withDuration: 1.1,
            delay: 0.4,
            usingSpringWithDamping: 0.55,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                self.titleLabel.transform = .identity
                self.titleLabel.alpha = 1
            },
            completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.goToOnboarding()
                }
            }
        )
    }

    // MARK: - Navigation
    private func goToOnboarding() {

        let onboardingVC = OnboardingViewController(
            nibName: "OnboardingViewController",
            bundle: nil
        )

        let navController = UINavigationController(rootViewController: onboardingVC)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        UIView.transition(
            with: window,
            duration: 0.8,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = navController
                window.makeKeyAndVisible()
            }
        )
    }
}
