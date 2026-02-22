//
//  ParentProfileViewController.swift
//  ChildProfile
//
//  Created by admin0 on 12/25/25.
//

import UIKit
import Supabase

class ParentProfileViewController: UIViewController {
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var helpView: UIView!

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var logoutView: UIView!

    @IBOutlet weak var deleteAccountView: UIView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.center = view.center
        activityIndicator.color = .systemGray
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)


        addTap(to: aboutView, type: .about)
        addTap(to: termsView, type: .terms)
        addTap(to: privacyView, type: .privacy)
        addTap(to: helpView, type: .help)
        
        logoutView.isUserInteractionEnabled = true
        logoutView.tag = 5
        logoutView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(infoTapped(_:)))
        )
        
//        deleteAccountView.isUserInteractionEnabled = true
//        deleteAccountView.addGestureRecognizer(
//            UITapGestureRecognizer(target: self, action: #selector(deleteAccountTapped))
//        )


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
        loadUserInfo()
    }

    private func addTap(to view: UIView, type: InfoViewController.InfoType) {
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(infoTapped(_:)))
        view.addGestureRecognizer(tap)
        view.tag = tag(for: type)
    }

    private func tag(for type: InfoViewController.InfoType) -> Int {
        switch type {
        case .about: return 1
        case .terms: return 2
        case .privacy: return 3
        case .help: return 4
        }
    }


    @objc private func infoTapped(_ sender: UITapGestureRecognizer) {
        
        Haptics.impact(.light)
        
        guard let tag = sender.view?.tag else { return }

        if tag == 5 {
            handleLogout()
            return
        }

        let vc = InfoViewController()
        vc.modalPresentationStyle = .pageSheet

        switch tag {
        case 1: vc.type = .about
        case 2: vc.type = .terms
        case 3: vc.type = .privacy
        case 4: vc.type = .help
        default: return
        }

        present(vc, animated: true)
    }


    
    private func loadUserInfo() {
        Task {
            do {
                let session = try await SupabaseAuthService.shared.client.auth.session
                let user = session.user

                let email = user.email ?? "No Email"

                let metadata = user.userMetadata

                let fullName =
                    metadata["full_name"]?.value as? String
                    ?? metadata["name"]?.value as? String
                    ?? "Parent"

                DispatchQueue.main.async {
                    self.userName.text = fullName
                    self.userEmail.text = email
                }

            } catch {
                print("❌ Failed to fetch user info:", error)
            }
        }
    }
    
    private func handleLogout() {

        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        let logout = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.performLogout()
        }

        alert.addAction(cancel)
        alert.addAction(logout)

        present(alert, animated: true)
    }

    private func performLogout() {
        
        Haptics.impact(.light)
        
        showLoader()

        Task {
            await SupabaseAuthService.shared.logout()

            await MainActor.run {

                // Clear entire app state
                AppState.shared.clear()

                guard
                    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let window = scene.windows.first
                else { return }

                let loginVC = LoginViewController(
                    nibName: "LoginViewController",
                    bundle: nil
                )

                let nav = UINavigationController(rootViewController: loginVC)

                UIView.transition(
                    with: window,
                    duration: 0.35,
                    options: .transitionCrossDissolve,
                    animations: {
                        window.rootViewController = nav
                        window.makeKeyAndVisible()
                    }
                )
            }
        }
    }


    
    private func showLoader() {
        view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }

    private func hideLoader() {
        view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }

    
    @IBAction func editNameTapped(_ sender: Any) {

        Haptics.impact(.light)

        let alert = UIAlertController(
            title: "Edit Name",
            message: "Update your display name",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Enter your name"
            textField.text = self.userName.text
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .whileEditing
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        let save = UIAlertAction(title: "Save", style: .default) { _ in

            guard let newName = alert.textFields?.first?.text,
                  !newName.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            self.updateUserName(newName)
        }

        alert.addAction(cancel)
        alert.addAction(save)

        present(alert, animated: true)
    }
    
    private func updateUserName(_ newName: String) {

        showLoader()

        Task {
            do {
                try await SupabaseAuthService.shared.client.auth.update(
                    user: .init(
                        data: ["full_name": .string(newName)]
                    )
                )

                await MainActor.run {
                    self.userName.text = newName
                    self.hideLoader()
                }

            } catch {

                await MainActor.run {
                    self.hideLoader()

                    let errorAlert = UIAlertController(
                        title: "Update Failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
        }
    }
    
//    @objc private func deleteAccountTapped() {
//
//        Haptics.notification(.warning)
//
//        let alert = UIAlertController(
//            title: "Delete Account",
//            message: "This action cannot be undone. All your data will be permanently deleted.",
//            preferredStyle: .alert
//        )
//
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
//
//        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
//            self.performAccountDeletion()
//        }
//
//        alert.addAction(cancel)
//        alert.addAction(delete)
//
//        present(alert, animated: true)
//    }
//
//    private func performAccountDeletion() {
//
//        showLoader()
//
//        Task {
//            do {
//                try await SupabaseAuthService.shared.client.functions.invoke(
//                    "delete-user"
//                )
//
//                await SupabaseAuthService.shared.logout()
//
//                await MainActor.run {
//                    self.hideLoader()
//
//                    AppState.shared.clear()
//
//                    guard
//                        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                        let window = scene.windows.first
//                    else { return }
//
//                    let loginVC = LoginViewController(
//                        nibName: "LoginViewController",
//                        bundle: nil
//                    )
//
//                    let nav = UINavigationController(rootViewController: loginVC)
//
//                    UIView.transition(
//                        with: window,
//                        duration: 0.35,
//                        options: .transitionCrossDissolve,
//                        animations: {
//                            window.rootViewController = nav
//                            window.makeKeyAndVisible()
//                        }
//                    )
//                }
//
//            } catch {
//
//                await MainActor.run {
//                    self.hideLoader()
//
//                    let errorAlert = UIAlertController(
//                        title: "Deletion Failed",
//                        message: error.localizedDescription,
//                        preferredStyle: .alert
//                    )
//                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
//                    self.present(errorAlert, animated: true)
//                }
//            }
//        }
//    }


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
