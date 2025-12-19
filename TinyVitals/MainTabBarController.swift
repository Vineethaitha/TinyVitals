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

        let records = RecordManagerViewController()
        records.tabBarItem = UITabBarItem(
            title: "Records",
            image: UIImage(systemName: "cross.case"),
            selectedImage: UIImage(systemName: "cross.case.fill")
        )

        let vaccine = VaccinationManagerViewController()
        vaccine.tabBarItem = UITabBarItem(
            title: "Vaccines",
            image: UIImage(systemName: "syringe"),
            selectedImage: UIImage(systemName: "syringe.fill")
        )

        viewControllers = [
            UINavigationController(rootViewController: records),
            UINavigationController(rootViewController: home),
            UINavigationController(rootViewController: vaccine)
        ]
    }
}


