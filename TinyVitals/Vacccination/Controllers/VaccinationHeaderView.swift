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

    var onRingTap: (() -> Void)?

    private let legendStack = UIStackView()
    private var didSetupLegend = false

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear

        // Enlarge ring for concentric design (XIB has 150×150)
        for constraint in progressRingView.constraints {
            if constraint.firstAttribute == .width ||
               constraint.firstAttribute == .height {
                constraint.constant = 200
            }
        }

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(ringTapped)
        )
        progressRingView.isUserInteractionEnabled = true
        progressRingView.addGestureRecognizer(tap)

        setupLegendStack()
    }

    // MARK: - Legend

    private func setupLegendStack() {
        guard !didSetupLegend else { return }
        didSetupLegend = true

        legendStack.axis = .horizontal
        legendStack.alignment = .center
        legendStack.distribution = .equalSpacing
        legendStack.spacing = 12
        legendStack.translatesAutoresizingMaskIntoConstraints = false

        // Insert into the parent UIStackView (ring's superview from XIB)
        if let parentStack = progressRingView.superview as? UIStackView {
            parentStack.addArrangedSubview(legendStack)
        }
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
        progressRingView.update(
            completed: completed,
            upcoming: upcoming,
            skipped: skipped,
            rescheduled: rescheduled
        )

        updateLegend(
            completed: completed,
            upcoming: upcoming,
            skipped: skipped,
            rescheduled: rescheduled
        )
    }

    private func updateLegend(
        completed: Int,
        upcoming: Int,
        skipped: Int,
        rescheduled: Int
    ) {
        legendStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let counts = [completed, upcoming, skipped, rescheduled]
        let colors = VaccinationProgressRingView.ringColors
        let labels = VaccinationProgressRingView.ringLabels

        for i in 0..<4 {
            guard counts[i] > 0 else { continue }

            let dot = UIView()
            dot.backgroundColor = colors[i]
            dot.layer.cornerRadius = 5
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 10).isActive = true

            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = .secondaryLabel
            label.text = labels[i]

            let pair = UIStackView(arrangedSubviews: [dot, label])
            pair.axis = .horizontal
            pair.spacing = 4
            pair.alignment = .center

            legendStack.addArrangedSubview(pair)
        }
    }
}
