//
//  homeViewController.swift
//  TinyVitals
//
//  Created by user70 on 04/11/25.
//

import UIKit

class homeViewController: UIViewController {

    @IBOutlet var childProfileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        childProfileImageView.layer.borderColor = UIColor.systemPink.cgColor
        // Do any additional setup after loading the view.
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
