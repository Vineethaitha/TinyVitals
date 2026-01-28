//
//  ForgotPasswordViewController.swift
//  sample work
//
//  Created by admin0 on 10/12/25.
//

import UIKit

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    private let authService: AuthService = FirebaseAuthService.shared

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendLinkButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendLinkButton.configuration = nil
        sendLinkButton.layer.cornerRadius = sendLinkButton.frame.height / 2
        sendLinkButton.clipsToBounds = true
        sendLinkButton.setTitle("Send link", for: .normal)
        sendLinkButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        self.title = "Password Recovery"
        emailTextField.delegate = self
        emailTextField.keyboardType = .emailAddress
    }
    
    // MARK: - Action

    @IBAction func sendResetLinkTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty else {
            self.showAlert(title: "Error", message: "Please enter your email address.")
            return
        }
        
//        showLoader()

        authService.resetPassword(email: email) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
//                self.hideLoader()

                switch result {
                case .success:
                    self.showAlert(
                        title: "Email Sent",
                        message: "Please check your inbox to reset your password."
                    )

                case .failure(let error):
                    self.showAlert(
                        title: "Failed",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
    
    // MARK: - Keyboard Management (Dismiss on Return Key)
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Keyboard Management (Dismiss on Tap Outside)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    // MARK: - Helper Methods (showAlerts)
    
    private func showAlertAndDismiss(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
