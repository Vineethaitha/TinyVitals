//  MainTabBarController.swift
//  ChildProfile
//
//  Created by admin0 on 12/21/25.
//
import UIKit

protocol ActiveChildReceivable: AnyObject {
    var activeChild: ChildProfile? { get set }
    func onActiveChildChanged()
}

class MainTabBarController: UITabBarController {
    
    // MARK: - State
    private var activeChild: ChildProfile? {
        AppState.shared.activeChild
    }



    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let home = HomeScreenViewController(
            nibName: "HomeScreenViewController",
            bundle: nil
        )

        home.activeChild = activeChild
        home.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let records = RecordManagerViewController(
            nibName: "RecordManagerViewController",
            bundle: nil
        )
        records.tabBarItem = UITabBarItem(
            title: "Records",
            image: UIImage(systemName: "cross.case"),
            selectedImage: UIImage(systemName: "cross.case.fill")
        )

        let symptoms = SymptomsTrackerViewController(
            nibName: "SymptomsTrackerViewController",
            bundle: nil
        )
        symptoms.tabBarItem = UITabBarItem(
            title: "Symptoms",
            image: UIImage(systemName: "stethoscope"),
            selectedImage: UIImage(systemName: "stethoscope")
        )

        let vaccine = VaccinationManagerViewController(
            nibName: "VaccinationManagerViewController",
            bundle: nil
        )
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

        tabBar.tintColor = UIColor(
            red: 237/255,
            green: 112/255,
            blue: 153/255,
            alpha: 1.0
        )
        tabBar.unselectedItemTintColor = .systemGray
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateNavBarTitles()

        if AppState.shared.children.isEmpty {
            presentAddChild()
        }
    }


    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateNavBarTitles()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let child = activeChild else { return }
        propagateActiveChild(child)
    }

    
    private func propagateActiveChild(_ child: ChildProfile) {
        viewControllers?.forEach { vc in
            guard let nav = vc as? UINavigationController,
                  let topVC = nav.topViewController
            else { return }

            if let homeVC = topVC as? HomeScreenViewController {
                homeVC.activeChild = child
//                homeVC.loadViewIfNeeded()
//                homeVC.setupVaccinationProgress()
                if homeVC.isViewLoaded {
                    homeVC.refreshForActiveChild()
                }
            }


            if let recordsVC = topVC as? RecordManagerViewController {
                recordsVC.activeChild = child

                if recordsVC.isViewLoaded {
                    recordsVC.reloadForChild()
                }
            }
            
            if let symptomsVC = topVC as? SymptomsTrackerViewController {
                symptomsVC.activeChild = child

                if symptomsVC.isViewLoaded {
                    symptomsVC.reloadForActiveChild()
                }
            }


            if let vaccineVC = topVC as? VaccinationManagerViewController {
                vaccineVC.activeChild = child

                if vaccineVC.isViewLoaded {
                    vaccineVC.reloadForChild()
                }
            }

        }
    }

    
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

    func handlePostDeleteFlow() {
        if AppState.shared.children.isEmpty {
            presentAddChild()
        } else if let newActive = AppState.shared.activeChild {
            propagateActiveChild(newActive)
            refreshNavBarForVisibleVC()
        }
    }


    @objc private func addChildTapped() {
        presentAddChild()
    }

    func presentAddChild() {
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

        vc.childrenProvider = {
            AppState.shared.children
        }

        vc.selectionDelegate = self
        vc.actionsDelegate = self   // 🔥 THIS LINE IS REQUIRED

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
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

// MARK: - Update Child Delegate

extension MainTabBarController: ChildProfileDelegate {

    func didUpdateChild(_ child: ChildProfile) {
        AppState.shared.updateChild(child)
        propagateActiveChild(child)
        updateNavBarTitles()
    }
}


extension MainTabBarController: AddChildDelegate {

    func didAddChild(_ child: ChildProfile) {
        AppState.shared.addChild(child)
        dismiss(animated: true)
        propagateActiveChild(child)
        updateNavBarTitles()
    }
}



extension MainTabBarController: ChildSelectionDelegate {
    func didSelectChild(_ child: ChildProfile) {
        AppState.shared.setActiveChild(child)
        propagateActiveChild(child)
        updateNavBarTitles()
    }
}

extension MainTabBarController: ChildSelectionActions {
    func requestAddChild() {
        print("🔥 requestAddChild received in MainTabBarController")
        presentAddChild()
    }
}

