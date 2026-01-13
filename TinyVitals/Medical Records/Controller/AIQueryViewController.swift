//
//  AIQueryViewController.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

import UIKit

class AIQueryViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var applyButton: UIButton!

    let store = RecordsStore.shared
    
    var activeChild: ChildProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }


    @IBAction func applyTapped() {
        let prompt = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        let results = AIQueryParser.filter(
            records: store.allFiles(for: activeChild.id),
            prompt: prompt
        )

        openResults(records: results)
    }

    private func openResults(records: [MedicalFile]) {
        let vc = RecordListViewController(
            nibName: "RecordListViewController",
            bundle: nil
        )

        vc.mode = .aiResults
        vc.aiFilteredFiles = records
        vc.title = "AI Results"

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIViewController {

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

