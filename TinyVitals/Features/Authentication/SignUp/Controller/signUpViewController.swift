//
//  signUpViewController.swift
//  TinyVitals
//
//  Created by user70 on 03/11/25.
//

import UIKit

class signUpViewController: UIViewController {

    
    @IBOutlet var tinyVitalsTitle: UILabel!
    
    @IBOutlet var tinyVitalsCaption: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tinyVitalsTitle.font = UIFont(name: "Sigmar-Regular", size: 40)
        tinyVitalsCaption.font = UIFont(name: "Sigmar-Regular", size: 24
        )
        
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "tabBarViewController") as! tabBarViewController
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
}
