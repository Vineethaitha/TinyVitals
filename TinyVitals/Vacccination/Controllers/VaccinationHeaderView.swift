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

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(ringTapped)
        )
        progressRingView.isUserInteractionEnabled = true
        progressRingView.addGestureRecognizer(tap)
    }

    @objc private func ringTapped() {
        onRingTap?()
    }

    func configure(
        completed: Int,
        upcoming: Int,
        skipped: Int,
        rescheduled: Int
    ) {
        progressLabel.text = "Progress"

        progressRingView.update(
            completed: completed,
            upcoming: upcoming,
            skipped: skipped,
            rescheduled: rescheduled
        )
    }
}
