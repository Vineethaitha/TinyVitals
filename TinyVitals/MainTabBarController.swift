//
//  MainTabBarController.swift
//  TinyVitals
//
//  Created by admin0 on 12/18/25.
//

//import UIKit
//
//class MainTabBarController: UITabBarController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let home = HomeScreenViewController()
//        home.tabBarItem = UITabBarItem(
//            title: "Home",
//            image: UIImage(systemName: "house"),
//            selectedImage: UIImage(systemName: "house.fill")
//        )
//
//        let records = RecordManagerViewController()
//        records.tabBarItem = UITabBarItem(
//            title: "Records",
//            image: UIImage(systemName: "cross.case"),
//            selectedImage: UIImage(systemName: "cross.case.fill")
//        )
//
//        let vaccine = VaccinationManagerViewController()
//        vaccine.tabBarItem = UITabBarItem(
//            title: "Vaccines",
//            image: UIImage(systemName: "syringe"),
//            selectedImage: UIImage(systemName: "syringe.fill")
//        )
//
//        viewControllers = [
//            UINavigationController(rootViewController: records),
//            UINavigationController(rootViewController: home),
//            UINavigationController(rootViewController: vaccine)
//        ]
//    }
//}


//
//  MainTabBarController.swift
//  ChildProfile
//
//  Created by admin0 on 12/21/25.
//
import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - State

    var allChildren: [ChildProfile] = [] {
        didSet {
            if activeChild == nil {
                activeChild = allChildren.first
            }
        }
    }

    var activeChild: ChildProfile? {
        didSet {
            guard let child = activeChild else { return }
            propagateActiveChild(child)
            updateNavBarTitles()
        }
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupTabs()
        let home = HomeScreenViewController()
        home.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let records = RecordManagerViewController()
//        records.activeChild = activeChild    ✅ REQUIRED
        records.tabBarItem = UITabBarItem(
            title: "Records",
            image: UIImage(systemName: "cross.case"),
            selectedImage: UIImage(systemName: "cross.case.fill")
        )

        
        let symptoms = SymptomsTrackerViewController()
        symptoms.tabBarItem = UITabBarItem(
            title: "Symptoms",
            image: UIImage(systemName: "stethoscope"),
            selectedImage: UIImage(systemName: "stethoscope")
        )

        let vaccine = VaccinationManagerViewController()
        vaccine.tabBarItem = UITabBarItem(
            title: "Vaccines",
            image: UIImage(systemName: "syringe"),
            selectedImage: UIImage(systemName: "syringe.fill")
        )
        
        let profile = ParentProfileViewController()
        profile.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        viewControllers = [
            UINavigationController(rootViewController: home),
            UINavigationController(rootViewController: records),
            UINavigationController(rootViewController: symptoms),
            UINavigationController(rootViewController: vaccine),
            UINavigationController(rootViewController: profile)
        ]
        updateNavBarTitles()
        
        tabBar.tintColor = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1.0)
        tabBar.unselectedItemTintColor = .systemGray
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateNavBarTitles()

        if allChildren.isEmpty {
            presentAddChild()
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateNavBarTitles()
    }
    
    
    private func propagateActiveChild(_ child: ChildProfile) {
        viewControllers?.forEach { vc in
            guard let nav = vc as? UINavigationController,
                  let topVC = nav.topViewController
            else { return }

            if let recordsVC = topVC as? RecordManagerViewController {
                recordsVC.activeChild = child
            }

//            if let calendarVC = topVC as? CalendarRecordsViewController {
//                calendarVC.activeChild = child
//            }
//
//            if let symptomsVC = topVC as? SymptomsTrackerViewController {
//                symptomsVC.activeChild = child
//            }
//
//            if let vaccineVC = topVC as? VaccinationManagerViewController {
//                vaccineVC.activeChild = child
//            }
        }
    }




    // MARK: - Setup

//    private func setupTabs() {

//        let homeVC = HomeScreenViewController()
//        homeVC.tabBarItem = UITabBarItem(
//            title: "Home",
//            image: UIImage(systemName: "house"),
//            selectedImage: UIImage(systemName: "house.fill")
//        )
//        let homeNav = UINavigationController(rootViewController: homeVC)
//
//        let recordVC = RecordManagerViewController()
//        recordVC.tabBarItem = UITabBarItem(
//            title: "Record",
//            image: UIImage(systemName: "cross.case"),
//            selectedImage: UIImage(systemName: "cross.case.fill")
//        )
//        let recordNav = UINavigationController(rootViewController: recordVC)
//
//        let vaccineVC = VaccinationManagerViewController()
//        vaccineVC.tabBarItem = UITabBarItem(
//            title: "Vaccination",
//            image: UIImage(systemName: "syringe"),
//            selectedImage: UIImage(systemName: "syringe.fill")
//        )
//        let vaccineNav = UINavigationController(rootViewController: vaccineVC)
//
//        let profileVC = ParentProfileViewController()
//        profileVC.tabBarItem = UITabBarItem(
//            title: "Profile",
//            image: UIImage(systemName: "person"),
//            selectedImage: UIImage(systemName: "person.fill")
//        )
//        let profileNav = UINavigationController(rootViewController: profileVC)

//        viewControllers = [homeNav, recordNav, vaccineNav, profileNav]
//    }


    // MARK: - Navigation Bar

//    private func updateNavBarTitles() {
//
//        viewControllers?.forEach { vc in
//            guard
//                let nav = vc as? UINavigationController,
//                let topVC = nav.topViewController
//            else { return }
//
//            // 🔹 Home VC → show Switch Child
//            if topVC is HomeScreenViewController {
//                topVC.navigationItem.rightBarButtonItem = makeSwitchChildButton()
//            }
//            // 🔹 AddChildVC → let AddChildVC control its own navbar
//            else if topVC is AddChildViewController {
//                topVC.navigationItem.rightBarButtonItem = nil
//            }
//            // 🔹 Everything else
//            else {
//                topVC.navigationItem.rightBarButtonItem = nil
//            }
//
//            // 🔹 Title (child name)
//            if let child = activeChild {
//                let titleButton = UIButton(type: .system)
//                titleButton.setTitle("\(child.name) ▾", for: .normal)
//                titleButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
//                titleButton.addTarget(self,
//                                      action: #selector(childNameTapped),
//                                      for: .touchUpInside)
//                topVC.navigationItem.titleView = titleButton
//            }
//        }
//    }
    
    private func updateNavBarTitles() {
        guard
            let nav = selectedViewController as? UINavigationController,
            let topVC = nav.topViewController
        else { return }

        // ❌ Let AddChildVC manage itself
        if topVC is AddChildViewController {
            topVC.navigationItem.leftBarButtonItem = nil
            topVC.navigationItem.rightBarButtonItem = nil
            topVC.navigationItem.titleView = nil
            return
        }


        applyChildNavBar(to: topVC)
    }




//    private func makeAddChildButton() -> UIBarButtonItem {
//        UIBarButtonItem(
//            image: UIImage(systemName: "plus"),
//            style: .plain,
//            target: self,
//            action: #selector(addChildTapped)
//        )
//    }

    // MARK: - Actions

//    @objc private func childNameTapped() {
//        guard let child = activeChild else { return }
//
//        let vc = AddChildViewController(
//            nibName: "AddChildViewController",
//            bundle: nil
//        )
//
//        vc.child = child
//        vc.mode = .view
//        vc.updateDelegate = self
//
//        if let nav = selectedViewController as? UINavigationController {
//            nav.pushViewController(vc, animated: true)
//        }
//    }

    @objc private func addChildTapped() {
        presentAddChild()
    }

    private func presentAddChild() {
        let vc = AddChildViewController(
            nibName: "AddChildViewController",
            bundle: nil
        )
        vc.mode = .add
        vc.addDelegate = self

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }





    
    func refreshNavBarForVisibleVC() {
        updateNavBarTitles()
    }

    private func makeSwitchChildButton() -> UIBarButtonItem {
        UIBarButtonItem(
            image: UIImage(systemName: "arrow.triangle.2.circlepath"),
            style: .plain,
            target: self,
            action: #selector(switchChildTapped)
        )
    }

    @objc private func switchChildTapped() {
        let vc = ChildSelectionViewController(
            nibName: "ChildSelectionViewController",
            bundle: nil
        )
        vc.childProfiles = allChildren

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = vc
            window.makeKeyAndVisible()
        }
    }
    
    private func applyChildNavBar(to vc: UIViewController) {
        guard let child = activeChild else { return }

        let titleView = ChildNavTitleView()
        titleView.configure(child: child)

        // 🔥 THIS is the key connection
        titleView.onTap = { [weak self] in
            self?.openChildProfile()
        }

        let leftItem = UIBarButtonItem(customView: titleView)

        let spacer = UIBarButtonItem(
            barButtonSystemItem: .fixedSpace,
            target: nil,
            action: nil
        )
        spacer.width = -8

        vc.navigationItem.leftBarButtonItems = [spacer, leftItem]
        vc.navigationItem.rightBarButtonItem = makeSwitchChildButton()
    }
    
    private func openChildProfile() {
        guard
            let child = activeChild,
            let nav = selectedViewController as? UINavigationController
        else { return }

        let vc = AddChildViewController(
            nibName: "AddChildViewController",
            bundle: nil
        )

        vc.child = child
        vc.mode = .view
        vc.updateDelegate = self

        nav.pushViewController(vc, animated: true)
    }
}

// MARK: - Add Child Delegate

extension MainTabBarController: AddChildDelegate {

    func didAddChild(_ child: ChildProfile) {
        allChildren.append(child)
        activeChild = child
    }
}

// MARK: - Update Child Delegate

extension MainTabBarController: ChildProfileDelegate {
    func didUpdateChild(_ child: ChildProfile) {
        activeChild = child
        if let index = allChildren.firstIndex(where: { $0.id == child.id }) {
            allChildren[index] = child
        }
    }
}



