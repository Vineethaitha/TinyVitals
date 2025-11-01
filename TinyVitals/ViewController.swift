//
//  ViewController.swift
//  TinyVitals
//
//  Created by user70 on 01/11/25.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {

    @IBOutlet var gradientView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        // Do any additional setup after loading the view.
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
}

