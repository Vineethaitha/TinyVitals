//
//  LoginViewController.swift
//  sample work
//
//  Created by admin0 on 08/12/25.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn


class LoginViewController: UIViewController {

    @IBOutlet weak var googleSignUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
//        if Auth.auth().currentUser != nil {
//            self.navigateToHome()
//        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let size = CGSize(width: 24, height: 24)
        let image = UIImage(named: "google-logo-png-webinar-optimizing-for-success-google-business-webinar-13")?.resize(to: size)
        
        googleSignUpButton.setImage(image, for: .normal)
        googleSignUpButton.imageView?.contentMode = .scaleAspectFit
    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let vc = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty,
              !password.isEmpty else {
            self.showAlert(title: "Required", message: "Please enter both email and password.")
            return
        }
        self.showLoader()

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.hideLoader()
            if let error = error {
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }
            print("User signed in: \(authResult?.user.uid ?? "N/A")")
            self.navigateToHome()
        }
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        let vc = ForgotPasswordViewController(nibName: "ForgotPasswordViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func googleSignUpTapped(_ sender: UIButton) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            self.showAlert(title: "Config Error", message: "Missing Firebase Client ID.")
            return
        }
        
        self.showLoader()

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            
            self.hideLoader()
            
            if let error = error {
                self.showAlert(title: "Google Sign-In Failed", message: error.localizedDescription)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.showAlert(title: "Google Error", message: "Failed to retrieve tokens.")
                return
            }

            let accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(title: "Firebase Auth Error", message: error.localizedDescription)
                    return
                }

                print("Google sign-in success")
                self.navigateToHome()
            }
        }
    }
    
    private func navigateToHome() {
        let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = homeVC
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
    
    private func showAlert(title: String, message: String) {
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
    
    @objc func dismissKeyboard() {
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

