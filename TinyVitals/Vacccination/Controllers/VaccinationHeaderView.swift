//
//  VaccinationHeaderView.swift
//  TinyVitals
//
//  Created by user66 on 20/12/25.
//

import Foundation
import UIKit

final class VaccinationHeaderView: UIView {


    @IBOutlet weak var progressRingView: VaccinationProgressRingView!
    @IBOutlet weak var progressLabel: UILabel!
    
    var onRingTap: (() -> Void)?
//    var progressColor: UIColor = .systemBlue
//    var trackColor: UIColor = UIColor.systemGray4.withAlphaComponent(0.4)
    
    

    func configure(
            completed: Int,
            upcoming: Int,
            skipped: Int,
            rescheduled: Int
        ) {
            let total = completed + upcoming + skipped + rescheduled
            let percent = total == 0 ? 0 : Int(Double(completed) / Double(total) * 100)

            progressLabel.text = "Vaccination Progress: \(percent)%"
//            progressRingView.progressColor = .appPink
//            progressRingView.trackColor = UIColor.appPinkLight


            progressRingView.update(
                completed: completed,
                upcoming: upcoming,
                skipped: skipped,
                rescheduled: rescheduled
            )

            // 🔥 forward tap
            progressRingView.onTap = { [weak self] in
                self?.onRingTap?()
            }
        }
    }
