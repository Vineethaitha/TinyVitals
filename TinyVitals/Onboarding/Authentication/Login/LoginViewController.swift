//
//  LoginViewController.swift
//  sample work
//
//  Created by admin0 on 08/12/25.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let authService: AuthService = SupabaseAuthService.shared

    @IBOutlet weak var googleSignUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var appleSignUpButton: UIButton!
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.configuration = nil
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.clipsToBounds = true
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        appleSignUpButton.configuration = nil
        appleSignUpButton.layer.cornerRadius = appleSignUpButton.frame.height / 2
        appleSignUpButton.clipsToBounds = true
        appleSignUpButton.setTitle("  Sign up with Apple", for: .normal)
        appleSignUpButton.setImage(UIImage(systemName: "apple.logo"), for: .normal)
        appleSignUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        setupLoader()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboard))
        view.addGestureRecognizer(tap)
        
        googleSignUpButton.configuration = nil
        googleSignUpButton.clipsToBounds = true
        googleSignUpButton.setTitle("  Sign up with Google", for: .normal)
        googleSignUpButton.setTitleColor(.label, for: .normal)
        googleSignUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        let size = CGSize(width: 24, height: 24)
        let image = UIImage(named: "GoogleLogo")?
            .resize(to: size)
            .withRenderingMode(.alwaysOriginal)

        googleSignUpButton.setImage(image, for: .normal)
        googleSignUpButton.imageView?.contentMode = .scaleAspectFit
        googleSignUpButton.tintColor = .clear

    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let vc = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        Haptics.impact(.light)
        guard let email = emailTextField.text,
                  let password = passwordTextField.text,
                  !email.isEmpty,
                  !password.isEmpty else {
                showAlert(title: "Required", message: "Please enter both email and password.")
                return
            }

            showLoader()

            authService.login(email: email, password: password) { [weak self] result in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.hideLoader()

                    switch result {
                    case .success(let userId):
                        AppState.shared.userId = userId
                        
                        Task {
                            do {
                                let userUUID = UUID(uuidString: userId)!
                                let dtos = try await ChildService.shared.fetchChildren(userId: userUUID)
                                let profiles = dtos.map { ChildProfile(dto: $0) }
                                
                                AppState.shared.setChildren(profiles)
                                
                                if let first = profiles.first {
                                    AppState.shared.setActiveChild(first)
                                }
                                
                                DispatchQueue.main.async {
                                    self.navigateToHome()
                                }
                                
                            } catch {
                                DispatchQueue.main.async {
                                    self.navigateToHome()
                                }
                            }
                        }


                    case .failure(let error):
                        self.showAlert(
                            title: "Login Failed",
                            message: error.localizedDescription
                        )
                    }
                }
            }
        }
    
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        let vc = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func googleSignUpTapped(_ sender: UIButton) {
        Haptics.impact(.light)
        showLoader()

            authService.signInWithGoogle(presentingVC: self) { [weak self] result in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.hideLoader()

                    switch result {
                    case .success(let userId):
                        AppState.shared.userId = userId
                        self.navigateToHome()

                    case .failure(let error):
                        self.showAlert(
                            title: "Google Sign-In Failed",
                            message: error.localizedDescription
                        )
                    }
                }
            }
        }
    
    private func navigateToHome() {

        let tabBar = MainTabBarController()

        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first
        else { return }

        window.rootViewController = tabBar
        window.makeKeyAndVisible()

        UIView.transition(
            with: window,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }




    
    private func showAlert(title: String, message: String) {
        Haptics.impact(.light)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func setupLoader() {
        activityIndicator.center = view.center
        activityIndicator.color = .systemGray
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
    }
    
    private func showLoader() {
        self.view.isUserInteractionEnabled = false // Prevent accidental taps (HIG)
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
    }

    private func hideLoader() {
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    @objc func handleDismissKeyboard() {
        view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

