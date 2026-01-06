//
//  VaccinationProgressRingView.swift
//  TinyVitals
//
//  Created by user66 on 20/12/25.
//

import UIKit

final class VaccinationProgressRingView: UIView {
    
    var onTap: (() -> Void)?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTap()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTap()
    }

    private func setupTap() {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        onTap?()
    }

    // MARK: - Layers
    private let trackLayer = CAShapeLayer()
    private let completedLayer = CAShapeLayer()
    private let upcomingLayer = CAShapeLayer()
    private let skippedLayer = CAShapeLayer()
    private let rescheduledLayer = CAShapeLayer()

    private let centerLabel = UILabel()

    // MARK: - Colors (Normal iOS system colors)
    private let completedColor = UIColor.systemGreen
    private let upcomingColor = UIColor.systemBlue
    private let skippedColor = UIColor.systemRed
    private let rescheduledColor = UIColor.systemOrange
    

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayers()
        setupLabel()
        setupTap()
    }

    private func setupLayers() {
        layer.sublayers?.removeAll()

        let radius = min(bounds.width, bounds.height) / 2 - 16
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let startAngle = -CGFloat.pi / 2

        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: startAngle + 2 * .pi,
            clockwise: true
        )

        let layers = [
            trackLayer,
            completedLayer,
            upcomingLayer,
            skippedLayer,
            rescheduledLayer
        ]

        layers.forEach {
            $0.path = path.cgPath
            $0.fillColor = UIColor.clear.cgColor
            $0.lineWidth = 16
            $0.lineCap = .round
        }

        // Background track
        trackLayer.strokeColor = UIColor.systemGray4.withAlphaComponent(0.4).cgColor
        trackLayer.strokeEnd = 1

        // Simple depth
        [completedLayer, upcomingLayer, skippedLayer, rescheduledLayer].forEach {
            $0.shadowColor = UIColor.black.cgColor
            $0.shadowOpacity = 0.1
            $0.shadowRadius = 2
            $0.shadowOffset = CGSize(width: 0, height: 1)
        }

        // Order matters
        layer.addSublayer(trackLayer)
        layer.addSublayer(completedLayer)
        layer.addSublayer(upcomingLayer)
        layer.addSublayer(skippedLayer)
        layer.addSublayer(rescheduledLayer)
    }

    private func setupLabel() {
        centerLabel.frame = bounds
        centerLabel.textAlignment = .center
        centerLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        centerLabel.textColor = .label
        addSubview(centerLabel)
    }

    // MARK: - Update
    func update(
        completed: Int,
        upcoming: Int,
        skipped: Int,
        rescheduled: Int
    ) {
        let total = completed + upcoming + skipped + rescheduled
        guard total > 0 else { return }

        let c = CGFloat(completed) / CGFloat(total)
        let u = CGFloat(upcoming) / CGFloat(total)
        let s = CGFloat(skipped) / CGFloat(total)

        animate(layer: completedLayer, from: 0, to: c, color: completedColor)
        animate(layer: upcomingLayer, from: c, to: c + u, color: upcomingColor)
        animate(layer: skippedLayer, from: c + u, to: c + u + s, color: skippedColor)
        animate(layer: rescheduledLayer, from: c + u + s, to: 1, color: rescheduledColor)

        let percent = Int(c * 100)
        centerLabel.text = "\(percent)%"

        handleHaptics(percent: percent)
        if percent == 100 { pulse() }
    }

    private func animate(
        layer: CAShapeLayer,
        from: CGFloat,
        to: CGFloat,
        color: UIColor
    ) {
        layer.strokeColor = color.cgColor
        layer.strokeStart = from
        layer.strokeEnd = to

        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = from
        anim.toValue = to
        anim.duration = 0.7
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(anim, forKey: "stroke")
    }

    // MARK: - Effects
    private func handleHaptics(percent: Int) {
        if [25, 50, 75, 100].contains(percent) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    private func pulse() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.04
        pulse.duration = 0.6
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        layer.add(pulse, forKey: "pulse")
    }
    
//    private func setupTap() {
//        if gestureRecognizers == nil {
//            let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
//            isUserInteractionEnabled = true
//            addGestureRecognizer(tap)
//        }
//    }

    @objc private func didTap() {
        onTap?()
    }

}
