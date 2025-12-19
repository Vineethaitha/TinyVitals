//
//  OnboardingViewController.swift
//  TinyVitals
//
//  Created by user45 on 07/11/25.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.configuration = nil
        continueButton.layer.cornerRadius = continueButton.frame.height / 2
        continueButton.clipsToBounds = true
        continueButton.setTitle("Continue", for: .normal)
        continueButton.tintColor = UIColor(red: 204/255, green: 142/255, blue: 224/255, alpha: 1)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
//        setupTitleLabel()
        // Do any additional setup after loading the view.
    }
    
//    private func setupTitleLabel() {
//        let titleText = NSMutableAttributedString()
//
//        let tinyAttributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: UIColor(red: 204/255, green: 142/255, blue: 224/255, alpha: 1),
//            .font: UIFont(name: "Sigmar-Regular", size: 40)!
//        ]
//        let vitalsAttributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: UIColor(red: 0x8D/255, green: 0xC0/255, blue: 0xD9/255, alpha: 1),
//            .font: UIFont(name: "Sigmar-Regular", size: 40)!
//        ]
//
//        titleText.append(NSAttributedString(string: "Tiny", attributes: tinyAttributes))
//        titleText.append(NSAttributedString(string: "Vitals", attributes: vitalsAttributes))
//
//        titleLabel.attributedText = titleText
//        titleLabel.textAlignment = .center
//    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        navigationController?.pushViewController(loginVC, animated: true)
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
