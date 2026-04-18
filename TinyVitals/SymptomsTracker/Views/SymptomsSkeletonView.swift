import UIKit

/// Skeleton loader for the Symptoms Tracker screen.
/// Matches the calendar strip + timeline list layout.
class SymptomsSkeletonView: ShimmerSkeletonView {

    override func buildLayout(in stack: UIStackView) {
        // ── 1. Calendar Day Strip ──
        stack.addArrangedSubview(makeChipsRow(count: 7, chipWidth: 52, chipHeight: 64, spacing: 8))

        // ── 2. Date Label ──
        stack.addArrangedSubview(makeSkeletonBar(height: 16, widthFraction: 0.55))

        // ── 3. Summary Label ──
        stack.addArrangedSubview(makeSkeletonBar(height: 12, widthFraction: 0.70))

        // ── 4. Spacer ──
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        stack.addArrangedSubview(spacer)

        // ── 5. Timeline Rows ──
        for _ in 0..<4 {
            stack.addArrangedSubview(makeSkeletonCard(height: 80, cornerRadius: 14))
        }
    }
}
