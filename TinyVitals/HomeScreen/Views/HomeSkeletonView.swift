import UIKit

/// A reusable shimmer skeleton overlay that mimics the home screen layout.
/// Follows Apple HIG: uses system background colours, subtle animations,
/// and matches the real UI card spacing so the transition is seamless.
class HomeSkeletonView: ShimmerSkeletonView {

    override func buildLayout(in stack: UIStackView) {
        // ── 1. Section Title (Articles) ──
        stack.addArrangedSubview(makeSkeletonBar(height: 18, widthFraction: 0.25))

        // ── 2. Article Card ──
        stack.addArrangedSubview(makeSkeletonCard(height: 130, cornerRadius: 16))

        // ── 3. Page Dots ──
        stack.addArrangedSubview(makeDotsRow(count: 3))

        // ── 4. Section Title (Milestones) ──
        stack.addArrangedSubview(makeSkeletonBar(height: 18, widthFraction: 0.30))

        // ── 5. Milestone Card ──
        stack.addArrangedSubview(makeSkeletonCard(height: 80, cornerRadius: 14))

        // ── 6. Section Title (Upcoming Vaccination) ──
        stack.addArrangedSubview(makeSkeletonBar(height: 18, widthFraction: 0.50))

        // ── 7. Vaccination Card ──
        stack.addArrangedSubview(makeSkeletonCard(height: 64, cornerRadius: 14))

        // ── 8. Section Title (Growth Trend) ──
        stack.addArrangedSubview(makeSkeletonBar(height: 18, widthFraction: 0.35))

        // ── 9. Growth Cards (Side by Side) ──
        let growthRow = UIStackView()
        growthRow.axis = .horizontal
        growthRow.spacing = 12
        growthRow.distribution = .fillEqually
        growthRow.addArrangedSubview(makeSkeletonCard(height: 90, cornerRadius: 14))
        growthRow.addArrangedSubview(makeSkeletonCard(height: 90, cornerRadius: 14))
        stack.addArrangedSubview(growthRow)
    }
}
