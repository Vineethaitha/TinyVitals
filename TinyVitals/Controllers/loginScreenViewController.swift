//
//  loginScreenViewController.swift
//  TinyVitals
//
//  Created by user70 on 03/11/25.
//

import UIKit

class loginScreenViewController: UIViewController {

    
    @IBOutlet var tinyVitalsTitle: UILabel!
    
    @IBOutlet var tinyVitalsCaption: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tinyVitalsTitle.font=UIFont(name: "Sigmar-Regular", size: 40)
        tinyVitalsCaption.font=UIFont(name: "Sigmar-Regular", size: 24)
    }
    
    @IBAction func signInBottonTapped(_ sender: UIButton) {
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "signUpViewController") as! signUpViewController
        self.navigationController?.pushViewController(signUpVC, animated: true)
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
