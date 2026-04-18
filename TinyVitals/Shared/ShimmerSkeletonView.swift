import UIKit

/// Base class for all shimmer skeleton overlays.
/// Provides reusable building blocks (bars, cards, rows) and the
/// shimmer animation. Subclass and override `buildLayout(in:)` to
/// define screen-specific placeholder layouts.
///
/// Follows Apple HIG: system colours, subtle animation, clean transitions.
class ShimmerSkeletonView: UIView {

    // MARK: - Properties

    private var shimmerLayers: [CAGradientLayer] = []
    private let animationDuration: CFTimeInterval = 1.2

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShimmerFrames()
    }

    // MARK: - Subclass Override Point

    /// Override this in subclasses to define the skeleton layout.
    func buildLayout(in stack: UIStackView) {
        // Default: empty. Subclasses add their own placeholder views.
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = UIColor.systemGroupedBackground
        isUserInteractionEnabled = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        ])

        buildLayout(in: stack)
    }

    // MARK: - Building Blocks

    /// A single rounded bar placeholder (e.g. for section titles).
    func makeSkeletonBar(height: CGFloat, widthFraction: CGFloat) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let bar = UIView()
        bar.backgroundColor = UIColor.systemFill
        bar.layer.cornerRadius = height / 2
        bar.layer.cornerCurve = .continuous
        bar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bar)

        addShimmer(to: bar)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: height),
            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bar.topAnchor.constraint(equalTo: container.topAnchor),
            bar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            bar.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: widthFraction),
        ])

        return container
    }

    /// A rounded rectangle card placeholder with two inner content bars.
    func makeSkeletonCard(height: CGFloat, cornerRadius: CGFloat) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.secondarySystemGroupedBackground
        card.layer.cornerRadius = cornerRadius
        card.layer.cornerCurve = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false

        let innerStack = UIStackView()
        innerStack.axis = .vertical
        innerStack.spacing = 10
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(innerStack)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: height),
            innerStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            innerStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            innerStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])

        innerStack.addArrangedSubview(makeInnerBar(height: 14, widthFraction: 0.6))
        innerStack.addArrangedSubview(makeInnerBar(height: 10, widthFraction: 0.4))

        addShimmer(to: card)

        return card
    }

    /// A thin bar inside a card (content line).
    func makeInnerBar(height: CGFloat, widthFraction: CGFloat) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let bar = UIView()
        bar.backgroundColor = UIColor.systemFill
        bar.layer.cornerRadius = height / 2
        bar.layer.cornerCurve = .continuous
        bar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bar)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: height),
            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bar.topAnchor.constraint(equalTo: container.topAnchor),
            bar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            bar.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: widthFraction),
        ])

        return container
    }

    /// A row of small dots (e.g. for page controls).
    func makeDotsRow(count: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let dots = UIStackView()
        dots.axis = .horizontal
        dots.spacing = 6
        dots.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dots)

        for i in 0..<count {
            let dot = UIView()
            dot.backgroundColor = i == 0 ? UIColor.systemFill : UIColor.tertiarySystemFill
            dot.layer.cornerRadius = 3.5
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 7),
                dot.heightAnchor.constraint(equalToConstant: 7),
            ])
            dots.addArrangedSubview(dot)
        }

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 10),
            dots.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            dots.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }

    /// A horizontal row of rounded-rect placeholders (e.g. filter chips, calendar days).
    func makeChipsRow(count: Int, chipWidth: CGFloat, chipHeight: CGFloat, spacing: CGFloat = 8) -> UIView {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = spacing
        row.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(row)

        NSLayoutConstraint.activate([
            scroll.heightAnchor.constraint(equalToConstant: chipHeight),
            row.topAnchor.constraint(equalTo: scroll.topAnchor),
            row.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            row.heightAnchor.constraint(equalTo: scroll.heightAnchor),
        ])

        for _ in 0..<count {
            let chip = UIView()
            chip.backgroundColor = UIColor.secondarySystemFill
            chip.layer.cornerRadius = chipHeight / 2
            chip.layer.cornerCurve = .continuous
            chip.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                chip.widthAnchor.constraint(equalToConstant: chipWidth),
                chip.heightAnchor.constraint(equalToConstant: chipHeight),
            ])
            addShimmer(to: chip)
            row.addArrangedSubview(chip)
        }

        return scroll
    }

    /// A 3x3 grid of square-ish placeholders (e.g. folder grid).
    func makeGrid(columns: Int, rows: Int, cellHeight: CGFloat, spacing: CGFloat = 10) -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = spacing
        grid.translatesAutoresizingMaskIntoConstraints = false

        for _ in 0..<rows {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = spacing
            row.distribution = .fillEqually

            for _ in 0..<columns {
                let cell = UIView()
                cell.backgroundColor = UIColor.secondarySystemGroupedBackground
                cell.layer.cornerRadius = 12
                cell.layer.cornerCurve = .continuous
                cell.translatesAutoresizingMaskIntoConstraints = false
                cell.heightAnchor.constraint(equalToConstant: cellHeight).isActive = true
                addShimmer(to: cell)
                row.addArrangedSubview(cell)
            }

            grid.addArrangedSubview(row)
        }

        return grid
    }

    /// A table-row-like placeholder with a circle icon and two text lines.
    func makeListRow(iconSize: CGFloat = 40) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        // Circle icon
        let icon = UIView()
        icon.backgroundColor = UIColor.secondarySystemFill
        icon.layer.cornerRadius = iconSize / 2
        icon.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(icon)
        addShimmer(to: icon)

        // Title bar
        let title = UIView()
        title.backgroundColor = UIColor.systemFill
        title.layer.cornerRadius = 6
        title.layer.cornerCurve = .continuous
        title.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(title)

        // Subtitle bar
        let subtitle = UIView()
        subtitle.backgroundColor = UIColor.tertiarySystemFill
        subtitle.layer.cornerRadius = 5
        subtitle.layer.cornerCurve = .continuous
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(subtitle)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: iconSize + 16),

            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: iconSize),
            icon.heightAnchor.constraint(equalToConstant: iconSize),

            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            title.topAnchor.constraint(equalTo: icon.topAnchor, constant: 2),
            title.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.45),
            title.heightAnchor.constraint(equalToConstant: 14),

            subtitle.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            subtitle.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.30),
            subtitle.heightAnchor.constraint(equalToConstant: 10),
        ])

        return row
    }

    // MARK: - Shimmer Animation

    @discardableResult
    func addShimmer(to view: UIView) -> CAGradientLayer {
        let shimmer = CAGradientLayer()
        shimmer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor,
        ]
        shimmer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmer.locations = [0, 0.5, 1]
        shimmer.cornerRadius = view.layer.cornerRadius
        view.layer.addSublayer(shimmer)
        shimmerLayers.append(shimmer)
        return shimmer
    }

    private func updateShimmerFrames() {
        for shimmer in shimmerLayers {
            guard let parent = shimmer.superlayer else { continue }
            shimmer.frame = parent.bounds
        }
    }

    /// Call this after the view appears to start the shimmer animation.
    func startAnimating() {
        layoutIfNeeded()
        updateShimmerFrames()

        for shimmer in shimmerLayers {
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1.0, -0.5, 0.0]
            animation.toValue = [1.0, 1.5, 2.0]
            animation.duration = animationDuration
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shimmer.add(animation, forKey: "shimmer")
        }
    }

    /// Fade out and remove the skeleton.
    func stopAnimating(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}
