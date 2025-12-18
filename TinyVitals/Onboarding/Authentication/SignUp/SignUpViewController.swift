//
//  SignUpViewController.swift
//  sample work
//
//  Created by admin0 on 09/12/25.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    
    private let matchImageView = UIImageView()
    private let eyeImageView = UIImageView()
    private var isPasswordVisible = false
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.textContentType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no

        fullNameTextField.textContentType = .name

        passwordTextField.textContentType = .none
        confirmPasswordTextField.textContentType = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setupPasswordEyeIcon()
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        setupConfirmPasswordIcon()
        setupLoader()
    }
    
    private func setupConfirmPasswordIcon() {
        matchImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        matchImageView.contentMode = .scaleAspectFit
        confirmPasswordTextField.rightView = matchImageView
        confirmPasswordTextField.rightViewMode = .always
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        let password = passwordTextField.text ?? ""
        let confirm = confirmPasswordTextField.text ?? ""

        if confirm.isEmpty {
            matchImageView.image = nil
        } else if password == confirm {
            matchImageView.image = UIImage(systemName: "checkmark.circle.fill")
            matchImageView.tintColor = .systemGreen
        } else {
            matchImageView.image = UIImage(systemName: "xmark.circle.fill")
            matchImageView.tintColor = .systemRed
        }
    }
    
    private func setupPasswordEyeIcon() {
        eyeImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        eyeImageView.image = UIImage(systemName: "eye.slash.fill")
        eyeImageView.tintColor = .gray
        eyeImageView.contentMode = .scaleAspectFit
        eyeImageView.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePasswordVisibility))
        eyeImageView.addGestureRecognizer(tap)

        passwordTextField.rightView = eyeImageView
        passwordTextField.rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility() {
        isPasswordVisible.toggle()
        passwordTextField.isSecureTextEntry = !isPasswordVisible

        if isPasswordVisible {
            eyeImageView.image = UIImage(systemName: "eye.fill")
        } else {
            eyeImageView.image = UIImage(systemName: "eye.slash.fill")
        }
    }
    
    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              let fullName = fullNameTextField.text,
              !email.isEmpty,
              !password.isEmpty,
              !fullName.isEmpty else {
            
            self.showAlert(title: "Sign Up Error", message: "Please complete all fields.")
            return
        }
        guard password == confirmPassword else {
            self.showAlert(title: "Sign Up Error", message: "Passwords do not match.")
            return
        }
        
        self.showLoader()
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            self.hideLoader()
            
            if let error = error {
                print("Sign up error: \(error.localizedDescription)")
                self.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                return
            }

            if let user = authResult?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = fullName
                
                // Commit the display name change
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Error updating display name: \(error.localizedDescription)")
                    }
                    
                    print("User created: \(user.uid)")
                    // Navigate to Home after profile update (successful or failed)
                    self.navigateToHome()
                }
            } else {
                // Should only happen if there's an unexpected Firebase issue
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupLoader() {
        activityIndicator.center = view.center
        activityIndicator.color = .systemGray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
    }
    
    private func showLoader() {
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
    }

    private func hideLoader() {
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
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
