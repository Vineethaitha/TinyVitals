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

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    func configure(
            completed: Int,
            upcoming: Int,
            skipped: Int,
            rescheduled: Int
        ) {
            let total = completed + upcoming + skipped + rescheduled
            let percent = total == 0 ? 0 : Int(Double(completed) / Double(total) * 100)

            progressLabel.text = "Progress"
            progressRingView.update(
                completed: completed,
                upcoming: upcoming,
                skipped: skipped,
                rescheduled: rescheduled
            )

            progressRingView.onTap = { [weak self] in
                self?.onRingTap?()
            }
        }
    }
