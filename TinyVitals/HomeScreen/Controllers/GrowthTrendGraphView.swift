//
//  WeightTrendGraphView.swift
//  HomeScreen_Feat
//
//  Created by admin0 on 12/17/25.
//

import Foundation
import UIKit

final class GrowthTrendGraphView: UIView {

    private let minLabelSpacing: CGFloat = 18
    
    private let optimalLineColor = UIColor(
        red: 141/255,
        green: 192/255,
        blue: 217/255,
        alpha: 1
    )



    var metric: GrowthMetric = .weight {
        didSet { setNeedsDisplay() }
    }

    var data: [GrowthPoint] = [] {
        didSet {
            selectedPoint = data.last
            setNeedsDisplay()
        }
    }

    // MARK: - Private State
    private var selectedPoint: GrowthPoint?
    private let padding: CGFloat = 32

    // MARK: - Reference Tables
    private let optimalWeightByMonth: [Int: Double] = [
        0: 3.3, 1: 4.4, 2: 5.6, 3: 6.4, 4: 7.0,
        5: 7.53, 6: 7.94, 7: 8.3, 8: 8.62, 9: 8.9,
        10: 9.12, 11: 9.43, 12: 9.66
    ]

    private let optimalHeightByMonth: [Int: Double] = [
        0: 49.8, 1: 54.8, 2: 58.4, 3: 61.4, 4: 64.0,
        5: 66.0, 6: 67.5, 7: 69.0, 8: 70.6, 9: 71.8,
        10: 73.1, 11: 74.4, 12: 75.7
    ]

    // MARK: - Init
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

    // MARK: - Touch Handling
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        selectNearestPoint(at: touch.location(in: self).x)
    }

    private func selectNearestPoint(at x: CGFloat) {
        guard data.count > 1 else { return }

        let minMonth = data.first!.month
        let maxMonth = data.last!.month
        let width = bounds.width - 2 * padding

        let ratio = max(0, min(1, (x - padding) / width))
        let tappedMonth = Int(round(CGFloat(minMonth) + ratio * CGFloat(maxMonth - minMonth)))

        selectedPoint = data.min {
            abs($0.month - tappedMonth) < abs($1.month - tappedMonth)
        }

        setNeedsDisplay()
    }

    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        guard data.count > 1,
              let context = UIGraphicsGetCurrentContext() else { return }

        context.clear(rect)

        let values = data.map { $0.value }
        let minVal = values.min()!
        let maxVal = values.max()!

        let paddedMin = floor(minVal - 1)
        let paddedMax = ceil(maxVal + 1)

        func point(for item: GrowthPoint) -> CGPoint {
            let xRatio = CGFloat(item.month - data.first!.month) /
                         CGFloat(data.last!.month - data.first!.month)

            let yRatio = CGFloat((item.value - paddedMin) /
                                (paddedMax - paddedMin))

            let x = padding + xRatio * (rect.width - 2 * padding)
            let y = rect.height - padding - yRatio * (rect.height - 2 * padding)

            return CGPoint(x: x, y: y)
        }

        let points = data.map { point(for: $0) }

        // GRID
        let grid = UIBezierPath()
        for i in 0...4 {
            let y = rect.height - padding - CGFloat(i) * (rect.height - 2 * padding) / 4.0
            grid.move(to: CGPoint(x: padding, y: y))
            grid.addLine(to: CGPoint(x: rect.width - padding, y: y))
        }
        UIColor.systemGray4.setStroke()
        grid.setLineDash([4, 4], count: 2, phase: 0)
        grid.lineWidth = 1
        grid.stroke()

        // CURVE
        let curve = UIBezierPath()
        curve.move(to: points[0])
        for i in 1..<points.count {
            let mid = CGPoint(
                x: (points[i - 1].x + points[i].x) / 2,
                y: (points[i - 1].y + points[i].y) / 2
            )
            curve.addQuadCurve(to: mid, controlPoint: points[i - 1])
        }
        curve.addLine(to: points.last!)

        UIColor(red: 237/255, green: 112/255, blue: 157/255, alpha: 1).setStroke()
        curve.lineWidth = 2.5
        curve.stroke()

        // GRADIENT FILL
        let fill = curve.copy() as! UIBezierPath
        fill.addLine(to: CGPoint(x: points.last!.x, y: rect.height))
        fill.addLine(to: CGPoint(x: points.first!.x, y: rect.height))
        fill.close()

        context.saveGState()
        fill.addClip()

        let baseColor = UIColor(red: 237/255, green: 112/255, blue: 157/255, alpha: 1)

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                baseColor.withAlphaComponent(0.25).cgColor,
                UIColor.clear.cgColor
            ] as CFArray,
            locations: [0, 1]
        )!




        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: padding),
            end: CGPoint(x: 0, y: rect.height),
            options: []
        )
        context.restoreGState()

        // OPTIMAL LINE (dynamic per selected month)
        if let selected = selectedPoint {
            let optimal: Double? = metric == .weight
                ? optimalWeightByMonth[selected.month]
                : optimalHeightByMonth[selected.month]

            if let optimal = optimal {
                let ratio = (optimal - paddedMin) / (paddedMax - paddedMin)
                let optimalY = rect.height - padding -
                               CGFloat(ratio) * (rect.height - 2 * padding)

                // Draw dashed optimal line
                let line = UIBezierPath()
                line.move(to: CGPoint(x: padding, y: optimalY))
                line.addLine(to: CGPoint(x: rect.width - padding, y: optimalY))

//                optimalLineColor.setStroke()
                UIColor.systemBlue.setStroke()
                line.lineWidth = 1.5
                line.setLineDash([6, 4], count: 2, phase: 0)
                line.stroke()

                // Smart label positioning (avoid collision)
                let unit = metric == .weight ? "kg" : "cm"
                var optimalLabelY = optimalY - 18

                let selectedY = point(for: selected).y
                if abs(optimalLabelY - selectedY) < minLabelSpacing {
                    optimalLabelY = selectedY + minLabelSpacing
                }

                "Optimal \(String(format: "%.1f", optimal)) \(unit)".draw(
                    at: CGPoint(x: padding + 4, y: optimalLabelY),
                    withAttributes: [
                        .font: UIFont.systemFont(ofSize: 11, weight: .medium),
                        .foregroundColor: UIColor.systemBlue
                    ]
                )
            }
        }

        // SELECTED POINT
        if let selected = selectedPoint {
            let p = point(for: selected)

            // Vertical indicator line
            let vLine = UIBezierPath()
            vLine.move(to: CGPoint(x: p.x, y: padding))
            vLine.addLine(to: CGPoint(x: p.x, y: rect.height - padding))
            UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1).setStroke()
            vLine.setLineDash([4, 4], count: 2, phase: 0)
            vLine.lineWidth = 1
            vLine.stroke()

            // Dot
            let dotRadius: CGFloat = 4
            let dot = UIBezierPath(
                ovalIn: CGRect(
                    x: p.x - dotRadius,
                    y: p.y - dotRadius,
                    width: dotRadius * 2,
                    height: dotRadius * 2
                )
            )
            UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1).setFill()
            dot.fill()

            // SMART LABEL POSITIONING
            let unit = metric == .weight ? "kg" : "cm"
            let labelText = "\(String(format: "%.1f", selected.value)) \(unit)"

            var labelY = p.y - 18

            // Avoid top edge
            if labelY < padding {
                labelY = p.y + 12
            }

            // Avoid optimal label collision
            if let optimal = metric == .weight
                ? optimalWeightByMonth[selected.month]
                : optimalHeightByMonth[selected.month] {

                let ratio = (optimal - paddedMin) / (paddedMax - paddedMin)
                let optimalY = rect.height - padding -
                               CGFloat(ratio) * (rect.height - 2 * padding)

                if abs(labelY - optimalY) < minLabelSpacing {
                    labelY = optimalY + minLabelSpacing
                }
            }

            labelText.draw(
                at: CGPoint(x: p.x + 6, y: labelY),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                    .foregroundColor: UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
                ]
            )
        }

        
        // MARK: - Y AXIS LABELS (kg / cm)
        let unit = metric == .weight ? "kg" : "cm"

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.secondaryLabel
        ]

        let steps = 4
        let valueStep = (paddedMax - paddedMin) / Double(steps)

        for i in 0...steps {
            let value = paddedMin + Double(i) * valueStep

            let y = rect.height - padding
                - CGFloat(i) * (rect.height - 2 * padding) / CGFloat(steps)

            let text = "\(Int(value)) \(unit)"

            text.draw(
                at: CGPoint(x: 4, y: y - 8),
                withAttributes: labelAttrs
            )
        }
        
        // MARK: - X AXIS LABELS (months)
        let months = data.map { $0.month }

        for month in months {
            guard let item = data.first(where: { $0.month == month }) else { continue }
            let p = point(for: item)

            "\(month)m".draw(
                at: CGPoint(x: p.x - 10, y: rect.height - padding + 6),
                withAttributes: labelAttrs
            )
        }


    }
}
