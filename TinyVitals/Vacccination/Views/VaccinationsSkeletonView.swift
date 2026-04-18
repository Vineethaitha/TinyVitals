import UIKit

/// Skeleton loader for the Vaccination Manager screen.
/// Matches the filter chips + vaccine table list layout.
class VaccinationsSkeletonView: ShimmerSkeletonView {

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

        // ── 2. Age Group Filter Chips ──
        stack.addArrangedSubview(makeChipsRow(count: 6, chipWidth: 100, chipHeight: 30, spacing: 8))

        // ── 3. Progress Ring placeholder ──
        let ringContainer = UIView()
        ringContainer.translatesAutoresizingMaskIntoConstraints = false
        ringContainer.heightAnchor.constraint(equalToConstant: 180).isActive = true

        let ring = UIView()
        ring.backgroundColor = UIColor.secondarySystemGroupedBackground
        ring.layer.cornerRadius = 70
        ring.translatesAutoresizingMaskIntoConstraints = false
        ringContainer.addSubview(ring)
        addShimmer(to: ring)

        NSLayoutConstraint.activate([
            ring.centerXAnchor.constraint(equalTo: ringContainer.centerXAnchor),
            ring.centerYAnchor.constraint(equalTo: ringContainer.centerYAnchor),
            ring.widthAnchor.constraint(equalToConstant: 140),
            ring.heightAnchor.constraint(equalToConstant: 140),
        ])

        stack.addArrangedSubview(ringContainer)

        // ── 4. Section Title (Upcoming) ──
        stack.addArrangedSubview(makeSkeletonBar(height: 14, widthFraction: 0.25))

        // ── 5. Vaccine List Rows ──
        for _ in 0..<4 {
            stack.addArrangedSubview(makeListRow(iconSize: 40))
        }
    }
}
