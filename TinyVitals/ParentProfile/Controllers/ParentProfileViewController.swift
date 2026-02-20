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

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
        loadUserInfo()
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
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








    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
