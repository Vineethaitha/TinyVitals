import UIKit

/// Skeleton loader for the Records Manager screen.
/// Matches the 3-column folder grid layout.
class RecordsSkeletonView: ShimmerSkeletonView {

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

        // ── 3. 3x2 Folder Grid ──
        stack.addArrangedSubview(makeGrid(columns: 3, rows: 2, cellHeight: 120, spacing: 10))
    }
}
