//
//  ParentProfileViewController.swift
//  ChildProfile
//
//  Created by admin0 on 12/25/25.
//

import UIKit

class ParentProfileViewController: UIViewController {
    
    @IBOutlet weak var aboutView: UIView!
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var helpView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()

        addTap(to: aboutView, type: .about)
        addTap(to: termsView, type: .terms)
        addTap(to: privacyView, type: .privacy)
        addTap(to: helpView, type: .help)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? MainTabBarController)?.refreshNavBarForVisibleVC()
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
        guard let tag = sender.view?.tag else { return }

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



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
