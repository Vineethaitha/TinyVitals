//
//  SparklineView.swift
//  TinyVitals
//
//  Created by admin0 on 12/20/25.
//

import Foundation
import UIKit

final class SparklineView: UIView {

    var values: [Double] = [] {
        didSet { setNeedsDisplay() }
    }

    var lineColor: UIColor = .systemGray {
        didSet { setNeedsDisplay() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        guard values.count > 1 else { return }

        let minVal = values.min()!
        let maxVal = values.max()!
        let range = max(maxVal - minVal, 0.1)

        let path = UIBezierPath()
        var points: [CGPoint] = []

        // Build points + line
        for (index, value) in values.enumerated() {
            let x = CGFloat(index) / CGFloat(values.count - 1) * rect.width
            let yRatio = (value - minVal) / range
            let y = rect.height - CGFloat(yRatio) * rect.height

            let point = CGPoint(x: x, y: y)
            points.append(point)

            index == 0 ? path.move(to: point) : path.addLine(to: point)
        }

        // Draw line
        lineColor.setStroke()
        path.lineWidth = 2
        path.lineCapStyle = .round
        path.stroke()

        // Draw points
        for (index, point) in points.enumerated() {

            let isLast = index == points.count - 1
            let radius: CGFloat = isLast ? 4 : 2.5

            let dot = UIBezierPath(
                ovalIn: CGRect(
                    x: point.x - radius,
                    y: point.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
            )

            lineColor.setFill()
            dot.fill()
        }
    }

}
