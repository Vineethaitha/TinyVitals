//
//  welcomeScreenViewController.swift
//  TinyVitals
//
//  Created by user70 on 02/11/25.
//

import UIKit

class welcomeScreenViewController: UIViewController {

    @IBOutlet var gradientView: UIView!
    
    @IBOutlet var tinyvitalsTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        tinyvitalsTitle.font=UIFont(name: "Sigmar-Regular", size: 40)
    }
    func setupGradient() {
        let gradientLayer = CAGradientLayer()
        let colorTop = UIColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 1.0).cgColor // Blue
        let colorBottom = UIColor(red: 0.9, green: 0.1, blue: 0.5, alpha: 1.0).cgColor // Pink
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) // Top-Left
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)   // Bottom-Right (Diagonal gradient)
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginScreenViewController") as! loginScreenViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }

    
}
