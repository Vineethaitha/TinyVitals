import UIKit

/// Skeleton loader for the Symptoms Selection screen.
/// Matches the search bar + 2-column symptom chip grid layout.
class SymptomsSelectionSkeletonView: ShimmerSkeletonView {

    override func buildLayout(in stack: UIStackView) {
        // ── 1. Search Bar placeholder ──
        let searchBar = UIView()
        searchBar.backgroundColor = UIColor.secondarySystemFill
        searchBar.layer.cornerRadius = 10
        searchBar.layer.cornerCurve = .continuous
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        addShimmer(to: searchBar)
        stack.addArrangedSubview(searchBar)

        // ── 2. Spacer ──
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        stack.addArrangedSubview(spacer)

        // ── 3. 2-column symptom chip grid (6 rows) ──
        for _ in 0..<6 {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 12
            row.distribution = .fillEqually

            let chip1 = makeChipPlaceholder()
            let chip2 = makeChipPlaceholder()
            row.addArrangedSubview(chip1)
            row.addArrangedSubview(chip2)

            stack.addArrangedSubview(row)
        }
    }

    private func makeChipPlaceholder() -> UIView {
        let chip = UIView()
        chip.backgroundColor = UIColor.secondarySystemGroupedBackground
        chip.layer.cornerRadius = 12
        chip.layer.cornerCurve = .continuous
        chip.translatesAutoresizingMaskIntoConstraints = false
        chip.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Inner icon circle + text bar
        let icon = UIView()
        icon.backgroundColor = UIColor.tertiarySystemFill
        icon.layer.cornerRadius = 14
        icon.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(icon)

        let text = UIView()
        text.backgroundColor = UIColor.systemFill
        text.layer.cornerRadius = 5
        text.layer.cornerCurve = .continuous
        text.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(text)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 10),
            icon.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),

            text.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8),
            text.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
            text.widthAnchor.constraint(equalTo: chip.widthAnchor, multiplier: 0.4),
            text.heightAnchor.constraint(equalToConstant: 12),
        ])

        addShimmer(to: chip)

        return chip
    }
}
