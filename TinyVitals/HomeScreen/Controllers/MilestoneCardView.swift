//
//  MilestoneCardView.swift
//  TinyVitals
//

import UIKit

final class MilestoneCardView: UIView {

    // MARK: - Brand color

    private let brandPink = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)

    // MARK: - Callback

    var onTap: (() -> Void)?

    // MARK: - UI

    private let cardView      = UIView()
    private let iconView      = UIImageView()
    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()
    private let descLabel     = UILabel()
    private let ringView      = CircularProgressRing()
    private let fractionLabel = UILabel()
    private let chevronView   = UIImageView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
        addTap()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
        addTap()
    }

    // MARK: - Layout

    private func buildUI() {
        backgroundColor = .clear

        // Card
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
        pin(cardView, to: self)

        // Icon (SF Symbol, tinted with category color)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconView)

        // Title — milestone name
        titleLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 17, weight: .semibold))
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        // Subtitle — category + expected age
        subtitleLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 13, weight: .regular))
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(subtitleLabel)

        // Description
        descLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 13, weight: .regular))
        descLabel.textColor = .tertiaryLabel
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(descLabel)

        // Progress ring
        ringView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(ringView)

        // Fraction label (inside ring)
        fractionLabel.font = UIFontMetrics.default.scaledFont(for: .monospacedDigitSystemFont(ofSize: 10, weight: .semibold))
        fractionLabel.textColor = brandPink
        fractionLabel.textAlignment = .center
        fractionLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(fractionLabel)

        // Chevron
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        chevronView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        chevronView.tintColor = .tertiaryLabel
        chevronView.contentMode = .scaleAspectFit
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(chevronView)

        let pad: CGFloat = 16

        NSLayoutConstraint.activate([
            // Icon
            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: pad),
            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),

            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: ringView.leadingAnchor, constant: -8),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: ringView.leadingAnchor, constant: -8),

            // Description
            descLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: pad),
            descLabel.trailingAnchor.constraint(equalTo: ringView.leadingAnchor, constant: -8),
            descLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),

            // Ring
            ringView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            ringView.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -12),
            ringView.widthAnchor.constraint(equalToConstant: 40),
            ringView.heightAnchor.constraint(equalToConstant: 40),

            // Fraction (centered inside ring)
            fractionLabel.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            fractionLabel.centerYAnchor.constraint(equalTo: ringView.centerYAnchor),

            // Chevron
            chevronView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -pad),
            chevronView.widthAnchor.constraint(equalToConstant: 8),
        ])
    }

    // MARK: - Configure

    func configure(dob: Date) {
        let snap = MilestoneService.snapshot(for: dob)
        guard let current = snap.current else { return }

        // SF Symbol icon with category color
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconView.image = UIImage(systemName: current.category.icon, withConfiguration: symbolConfig)
        iconView.tintColor = current.category.color

        // Title
        titleLabel.text = current.title

        // Subtitle — "Motor · Expected by 1 year 3 mo"
        let mo = current.ageMonths
        let ageText: String
        if mo >= 12 {
            let yrs = mo / 12
            let rem = mo % 12
            ageText = rem > 0 ? "\(yrs)y \(rem)m" : "\(yrs) year\(yrs > 1 ? "s" : "")"
        } else {
            ageText = "\(mo) months"
        }
        subtitleLabel.text = "\(current.category.rawValue) · Expected by \(ageText)"

        // Description
        descLabel.text = current.description

        // Ring
        ringView.trackColor = .systemGray5
        ringView.progressColor = brandPink
        ringView.setProgress(CGFloat(snap.progress), animated: true)

        // Percentage fraction
        let pct = Int(snap.progress * 100)
        fractionLabel.text = "\(pct)%"

        setNeedsLayout()
    }

    // MARK: - Tap

    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    @objc private func tapped() {
        Haptics.impact(.light)
        UIView.animate(withDuration: 0.08, animations: {
            self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.transform = .identity
            }
        }
        onTap?()
    }

    // MARK: - Helpers

    private func pin(_ child: UIView, to parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ])
    }
}

// MARK: - Circular Progress Ring

final class CircularProgressRing: UIView {

    var trackColor: UIColor = .systemGray5 {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }
    var progressColor: UIColor = .systemPink {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 3.5
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 3.5
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = (min(bounds.width, bounds.height) - 4) / 2
        let path = UIBezierPath(
            arcCenter: center, radius: radius,
            startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true
        )
        trackLayer.path = path.cgPath
        trackLayer.strokeColor = trackColor.cgColor
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = progressColor.cgColor
    }

    func setProgress(_ value: CGFloat, animated: Bool) {
        let clamped = min(max(value, 0), 1)
        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = progressLayer.strokeEnd
            anim.toValue = clamped
            anim.duration = 0.5
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(anim, forKey: "progress")
        }
        progressLayer.strokeEnd = clamped
    }
}
