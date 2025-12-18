//
//  MainTabBarController.swift
//  TinyVitals
//
//  Created by admin0 on 12/18/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let home = HomeScreenViewController()
        home.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

//        let profile = HomeViewController()
//        profile.tabBarItem = UITabBarItem(
//            title: "Profile",
//            image: UIImage(systemName: "person"),
//            selectedImage: UIImage(systemName: "person.fill")
//        )

        viewControllers = [
            UINavigationController(rootViewController: home),
//            UINavigationController(rootViewController: profile)
        ]
    }
}

