//
//  VaccinationProgressRingView.swift
//  TinyVitals
//
//  Created by user66 on 20/12/25.
//

import UIKit

final class VaccinationProgressRingView: UIView {

    // MARK: - Public

    var onTap: (() -> Void)?

    /// Apple Health-style concentric rings. Same API as before.
    func update(
        completed: Int,
        upcoming: Int,
        skipped: Int,
        rescheduled: Int
    ) {
        let total = completed + upcoming + skipped + rescheduled
        guard total > 0 else {
            centerLabel.text = "0%"
            applyProgress(values: [0, 0, 0, 0], animated: false)
            return
        }

        let values: [CGFloat] = [
            CGFloat(completed)   / CGFloat(total),
            CGFloat(upcoming)    / CGFloat(total),
            CGFloat(skipped)     / CGFloat(total),
            CGFloat(rescheduled) / CGFloat(total)
        ]

        let percent = Int(values[0] * 100)
        centerLabel.text = "\(percent)%"

        handleHaptics(percent: percent)

        if percent == 100 {
            layer.removeAnimation(forKey: "pulse")
            pulse()
        }

        applyProgress(values: values, animated: true)
    }

    // MARK: - Theme Colors (brand palette)

    /// Brand Pink — rgb(237, 112, 153)
    static let brandPink = UIColor(
        red: 237/255, green: 112/255, blue: 153/255, alpha: 1
    )

    /// Brand Blue — rgb(112, 210, 237)
    static let brandBlue = UIColor(
        red: 112/255, green: 210/255, blue: 237/255, alpha: 1
    )

    // Ring color mapping (outer → inner)
    static let ringColors: [UIColor] = [
        .systemGreen,                       // Completed
        VaccinationProgressRingView.brandPink,  // Upcoming
        .systemRed,                         // Skipped
        VaccinationProgressRingView.brandBlue   // Rescheduled
    ]

    static let ringLabels = ["Completed", "Upcoming", "Skipped", "Rescheduled"]

    // MARK: - Ring Metrics

    private let ringLineWidth: CGFloat = 14
    private let ringSpacing: CGFloat   = 4

    // MARK: - Layers

    private var trackLayers:    [CAShapeLayer] = []
    private var progressLayers: [CAShapeLayer] = []

    private let centerLabel = UILabel()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        setupTap()
        setupLayers()
        setupLabel()
    }

    // MARK: - Tap

    private func setupTap() {
        isUserInteractionEnabled = true
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }

    @objc private func handleTap() { onTap?() }

    // MARK: - Layer Setup

    private func setupLayers() {

        let colors = Self.ringColors

        for i in 0..<4 {
            // Track (faded background ring)
            let track = CAShapeLayer()
            track.fillColor   = UIColor.clear.cgColor
            track.lineWidth   = ringLineWidth
            track.lineCap     = .round
            track.strokeColor = colors[i].withAlphaComponent(0.15).cgColor
            track.strokeStart = 0
            track.strokeEnd   = 1
            layer.addSublayer(track)
            trackLayers.append(track)

            // Progress arc
            let arc = CAShapeLayer()
            arc.fillColor   = UIColor.clear.cgColor
            arc.lineWidth   = ringLineWidth
            arc.lineCap     = .round
            arc.strokeColor = colors[i].cgColor
            arc.strokeStart = 0
            arc.strokeEnd   = 0
            arc.shadowColor   = colors[i].cgColor
            arc.shadowOpacity = 0.3
            arc.shadowRadius  = 4
            arc.shadowOffset  = .zero
            layer.addSublayer(arc)
            progressLayers.append(arc)
        }
    }

    // MARK: - Center Label

    private func setupLabel() {
        centerLabel.textAlignment = .center
        centerLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        centerLabel.textColor = .label
        centerLabel.text = "0%"
        addSubview(centerLabel)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePaths()
        layoutCenterLabel()
    }

    private func updatePaths() {

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let outerRadius = min(bounds.width, bounds.height) / 2
            - ringLineWidth / 2
            - 2

        let startAngle = -CGFloat.pi / 2

        for i in 0..<4 {
            let r = outerRadius - CGFloat(i) * (ringLineWidth + ringSpacing)
            let path = UIBezierPath(
                arcCenter:  center,
                radius:     max(r, 0),
                startAngle: startAngle,
                endAngle:   startAngle + 2 * .pi,
                clockwise:  true
            )
            trackLayers[i].path    = path.cgPath
            progressLayers[i].path = path.cgPath
        }
    }

    private func layoutCenterLabel() {
        let outerRadius = min(bounds.width, bounds.height) / 2
            - ringLineWidth / 2 - 2
        let innerRadius = outerRadius - 3 * (ringLineWidth + ringSpacing)
        let labelSize = max(innerRadius * 2 - 8, 40)
        centerLabel.frame = CGRect(
            x: bounds.midX - labelSize / 2,
            y: bounds.midY - labelSize / 2,
            width: labelSize,
            height: labelSize
        )
    }

    // MARK: - Progress Animation

    private func applyProgress(values: [CGFloat], animated: Bool) {

        for (i, arc) in progressLayers.enumerated() {
            arc.removeAllAnimations()

            let target = values[i]
            arc.strokeEnd = target

            if animated && target > 0 {
                let anim = CABasicAnimation(keyPath: "strokeEnd")
                anim.fromValue = 0
                anim.toValue = target
                anim.duration = 0.9
                anim.timingFunction = CAMediaTimingFunction(
                    name: .easeInEaseOut
                )
                arc.add(anim, forKey: "progress")
            }
        }
    }

    // MARK: - Effects

    private func handleHaptics(percent: Int) {
        if [25, 50, 75, 100].contains(percent) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    private func pulse() {
        let p = CABasicAnimation(keyPath: "transform.scale")
        p.fromValue = 1.0
        p.toValue = 1.04
        p.duration = 0.6
        p.autoreverses = true
        p.repeatCount = .infinity
        layer.add(p, forKey: "pulse")
    }
}
