//
//  MilestoneCardView.swift
//  TinyVitals
//

import UIKit

private final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
}

final class MilestoneCardView: UIView {

    // MARK: - Brand colors

    private let brandPink = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
    private let brandBlue = UIColor(red: 112/255, green: 210/255, blue: 237/255, alpha: 1)

    // MARK: - UI Elements

    private let cardView        = UIView()
    private let titleLabel      = UILabel()     // Main milestone (Pink, bold)
    private let subtitleLabel   = UILabel()     // Category & Age (Black, medium)
    private let descLabel       = UILabel()     // Description (Gray, regular)
    
    private let progressTrack   = UIView()
    private let progressFill    = GradientView()
    
    private let prevLabel       = UILabel()
    private let nextLabel       = UILabel()

    private var fillWidthConstraint: NSLayoutConstraint?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    // MARK: - Build UI

    private func buildUI() {
        backgroundColor = .clear

        // ── Card ──
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
        pin(cardView, to: self)

        // ── Title (matches "17 days left" styling: 20pt Bold Pink) ──
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = brandPink
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        // ── Subtitle (matches "Vaccine Group" styling: 15pt Medium Black) ──
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = .label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(subtitleLabel)

        // ── Description ──
        descLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(descLabel)

        // ── Progress track ──
        progressTrack.backgroundColor = UIColor.systemGray5
        progressTrack.layer.cornerRadius = 3
        progressTrack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(progressTrack)

        // ── Progress fill (gradient: brand pink → brand blue) ──
        progressFill.layer.cornerRadius = 3
        progressFill.clipsToBounds = true
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressTrack.addSubview(progressFill)

        progressFill.gradientLayer.colors = [brandPink.cgColor, brandBlue.cgColor]
        progressFill.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        progressFill.gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)

        // ── Bottom labels ──
        prevLabel.font = .systemFont(ofSize: 12, weight: .medium)
        prevLabel.textColor = .tertiaryLabel
        prevLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(prevLabel)

        nextLabel.font = .systemFont(ofSize: 12, weight: .medium)
        nextLabel.textColor = brandPink
        nextLabel.textAlignment = .right
        nextLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nextLabel)

        // ── Constraints ──
        let p: CGFloat = 20

        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: p),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -p),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: p),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -p),

            // Description
            descLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            descLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: p),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -p),

            // Progress Track
            progressTrack.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 16),
            progressTrack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: p),
            progressTrack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -p),
            progressTrack.heightAnchor.constraint(equalToConstant: 6),

            // Progress Fill
            progressFill.topAnchor.constraint(equalTo: progressTrack.topAnchor),
            progressFill.leadingAnchor.constraint(equalTo: progressTrack.leadingAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressTrack.bottomAnchor),

            // Prev / Next Labels
            prevLabel.topAnchor.constraint(equalTo: progressTrack.bottomAnchor, constant: 10),
            prevLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: p),
            prevLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),

            nextLabel.centerYAnchor.constraint(equalTo: prevLabel.centerYAnchor),
            nextLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -p),
            nextLabel.leadingAnchor.constraint(greaterThanOrEqualTo: prevLabel.trailingAnchor, constant: 10)
        ])

        fillWidthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)
        fillWidthConstraint?.isActive = true
    }

    // MARK: - Configure

    func configure(dob: Date) {
        let snap = MilestoneService.snapshot(for: dob)
        guard let current = snap.current else { return }

        // Main Title (e.g. "Walks Independently")
        titleLabel.text = current.title
        
        // Subtitle (e.g. "Motor Development • 15 months")
        let mo = current.ageMonths
        let ageText = mo >= 12
            ? "\(mo / 12) year\(mo / 12 > 1 ? "s" : "") \(mo % 12 > 0 ? "\(mo % 12) mo" : "")"
            : "\(mo) months"
        subtitleLabel.text = "\(current.category.rawValue) Development • \(ageText)"

        // Description
        descLabel.text = current.description

        // Progress fill
        fillWidthConstraint?.isActive = false
        fillWidthConstraint = progressFill.widthAnchor.constraint(
            equalTo: progressTrack.widthAnchor,
            multiplier: max(CGFloat(snap.progress), 0.02)
        )
        fillWidthConstraint?.isActive = true

        // Previous milestone
        if let prev = snap.previous {
            prevLabel.text = "✓ \(prev.title) (\(prev.ageMonths) mo)"
        } else {
            prevLabel.text = "Starting the journey!"
        }

        // Next milestone
        if let next = snap.next {
            nextLabel.text = "\(next.title) (\(next.ageMonths) mo) →"
        } else {
            nextLabel.text = "All done! 🎉"
        }

        setNeedsLayout()
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
