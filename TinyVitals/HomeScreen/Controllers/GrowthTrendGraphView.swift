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
    
    var childAgeInMonths: Int = 0 {
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
    // MARK: - ICMR Reference Data (Boys)

    private let boysWeight: [Int: Double] = [
        0: 3.3,
        3: 6.0,
        6: 7.8,
        9: 9.2,
        12: 10.2,
        24: 12.3,
        36: 14.6,
        48: 16.7,
        60: 18.7,
        72: 20.7,
        84: 22.9,
        96: 25.3,
        108: 28.1,
        120: 31.4,
        132: 32.2,
        144: 37.0,
        156: 40.9,
        168: 47.0,
        180: 52.6,
        192: 58.0,
        204: 62.7,
        216: 65.0
    ]

    private let boysHeight: [Int: Double] = [
        0: 50.5,
        3: 61.1,
        6: 67.8,
        9: 72.3,
        12: 76.1,
        24: 85.6,
        36: 94.9,
        48: 102.9,
        60: 109.9,
        72: 116.1,
        84: 121.7,
        96: 127.0,
        108: 132.2,
        120: 137.5,
        132: 140.0,
        144: 147.0,
        156: 153.0,
        168: 160.0,
        180: 166.0,
        192: 171.0,
        204: 175.0,
        216: 177.0
    ]

    // MARK: - ICMR Reference Data (Girls)

    private let girlsWeight: [Int: Double] = [
        0: 3.2,
        3: 5.4,
        6: 7.2,
        9: 8.6,
        12: 9.5,
        24: 11.8,
        36: 14.1,
        48: 16.0,
        60: 17.7,
        72: 19.5,
        84: 21.8,
        96: 24.8,
        108: 28.5,
        120: 32.5,
        132: 33.7,
        144: 38.7,
        156: 44.0,
        168: 48.0,
        180: 51.5,
        192: 53.0,
        204: 54.0,
        216: 54.4
    ]

    private let girlsHeight: [Int: Double] = [
        0: 49.9,
        3: 60.2,
        6: 66.6,
        9: 71.1,
        12: 75.0,
        24: 84.5,
        36: 93.9,
        48: 101.6,
        60: 108.4,
        72: 114.6,
        84: 120.6,
        96: 126.4,
        108: 132.2,
        120: 138.3,
        132: 142.0,
        144: 148.0,
        156: 150.0,
        168: 155.0,
        180: 161.0,
        192: 162.0,
        204: 163.0,
        216: 164.0
    ]
    
    var childGender: String = "boy"


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
//    override func draw(_ rect: CGRect) {
//        guard data.count >= 1,
//              let context = UIGraphicsGetCurrentContext() else { return }
//        
//        if data.count == 1 {
//
//            let single = data[0]
//
//            let paddedMin = single.value - 2
//            let paddedMax = single.value + 2
//
//            let yRatio: CGFloat = 0.5
//            let x = bounds.midX
//            let y = rect.height - padding - yRatio * (rect.height - 2 * padding)
//
//            let dot = UIBezierPath(
//                ovalIn: CGRect(x: x - 6, y: y - 6, width: 12, height: 12)
//            )
//            UIColor.systemPink.setFill()
//            dot.fill()
//
//            // Draw baseline
//            let line = UIBezierPath()
//            line.move(to: CGPoint(x: padding, y: y))
//            line.addLine(to: CGPoint(x: rect.width - padding, y: y))
//            UIColor.systemGray4.setStroke()
//            line.setLineDash([4,4], count: 2, phase: 0)
//            line.stroke()
//
//            return
//        }
//
//
//        context.clear(rect)
//
//        let values = data.map { $0.value }
//        let minVal = values.min()!
//        let maxVal = values.max()!
//
//        
//        let range = max(2, maxVal - minVal)
//        let paddedMin = minVal - range * 0.5
//        let paddedMax = maxVal + range * 0.5
//
//
//        func point(for item: GrowthPoint) -> CGPoint {
//            let monthRange = max(1, data.count - 1)
//
//            let index = data.firstIndex(where: { $0.month == item.month }) ?? 0
//            let xRatio = CGFloat(index) / CGFloat(monthRange)
//
//
//            let totalRange = max(1, paddedMax - paddedMin)
//            let yRatio = CGFloat((item.value - paddedMin) / totalRange)
//
//
//            let x = padding + xRatio * (rect.width - 2 * padding)
//            let y = rect.height - padding - yRatio * (rect.height - 2 * padding)
//
//            return CGPoint(x: x, y: y)
//        }
//
//        let points = data.map { point(for: $0) }
//
//        // GRID
//        let grid = UIBezierPath()
//        for i in 0...4 {
//            let y = rect.height - padding - CGFloat(i) * (rect.height - 2 * padding) / 4.0
//            grid.move(to: CGPoint(x: padding, y: y))
//            grid.addLine(to: CGPoint(x: rect.width - padding, y: y))
//        }
//        UIColor.systemGray4.setStroke()
//        grid.setLineDash([4, 4], count: 2, phase: 0)
//        grid.lineWidth = 1
//        grid.stroke()
//
//        // CURVE
//        let curve = UIBezierPath()
//        curve.move(to: points[0])
//        for i in 1..<points.count {
//            let prev = points[i - 1]
//            let current = points[i]
//            
//            let mid = CGPoint(
//                x: (prev.x + current.x) / 2,
//                y: (prev.y + current.y) / 2
//            )
//            
//            curve.addQuadCurve(to: mid, controlPoint: prev)
//        }
//        curve.addLine(to: points.last!)
//
//        UIColor(red: 237/255, green: 112/255, blue: 157/255, alpha: 1).setStroke()
//        curve.lineWidth = 2.5
//        curve.stroke()
//
//        // GRADIENT FILL
//        let fill = curve.copy() as! UIBezierPath
//        fill.addLine(to: CGPoint(x: points.last!.x, y: rect.height))
//        fill.addLine(to: CGPoint(x: points.first!.x, y: rect.height))
//        fill.close()
//
//        context.saveGState()
//        fill.addClip()
//
//        let baseColor = UIColor(red: 237/255, green: 112/255, blue: 157/255, alpha: 1)
//
//        let gradient = CGGradient(
//            colorsSpace: CGColorSpaceCreateDeviceRGB(),
//            colors: [
//                baseColor.withAlphaComponent(0.25).cgColor,
//                UIColor.clear.cgColor
//            ] as CFArray,
//            locations: [0, 1]
//        )!
//
//
//
//
//        context.drawLinearGradient(
//            gradient,
//            start: CGPoint(x: 0, y: padding),
//            end: CGPoint(x: 0, y: rect.height),
//            options: []
//        )
//        context.restoreGState()
//
//        // OPTIMAL LINE (dynamic per selected month)
//        if let selected = selectedPoint {
//            let childAgeMonth = childAgeInMonths
//
//            let optimal = metric == .weight
//                ? optimalWeightByMonth[childAgeMonth]
//                : optimalHeightByMonth[childAgeMonth]
//
//            if let optimal = optimal {
//                let ratio = (optimal - paddedMin) / (paddedMax - paddedMin)
//                let optimalY = rect.height - padding -
//                               CGFloat(ratio) * (rect.height - 2 * padding)
//
//                // Draw dashed optimal line
//                let line = UIBezierPath()
//                line.move(to: CGPoint(x: padding, y: optimalY))
//                line.addLine(to: CGPoint(x: rect.width - padding, y: optimalY))
//
////                optimalLineColor.setStroke()
//                UIColor.systemBlue.setStroke()
//                line.lineWidth = 1.5
//                line.setLineDash([6, 4], count: 2, phase: 0)
//                line.stroke()
//
//                // Smart label positioning (avoid collision)
//                let unit = metric == .weight ? "kg" : "ft"
//                var optimalLabelY = optimalY - 18
//
//                let selectedY = point(for: selected).y
//                if abs(optimalLabelY - selectedY) < minLabelSpacing {
//                    optimalLabelY = selectedY + minLabelSpacing
//                }
//
//                "Optimal \(String(format: "%.1f", optimal)) \(unit)".draw(
//                    at: CGPoint(x: padding + 4, y: optimalLabelY),
//                    withAttributes: [
//                        .font: UIFont.systemFont(ofSize: 11, weight: .medium),
//                        .foregroundColor: UIColor.systemBlue
//                    ]
//                )
//            }
//        }
//
//        // SELECTED POINT
//        if let selected = selectedPoint {
//            let p = point(for: selected)
//
//            // Vertical indicator line
//            let vLine = UIBezierPath()
//            vLine.move(to: CGPoint(x: p.x, y: padding))
//            vLine.addLine(to: CGPoint(x: p.x, y: rect.height - padding))
//            UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1).setStroke()
//            vLine.setLineDash([4, 4], count: 2, phase: 0)
//            vLine.lineWidth = 1
//            vLine.stroke()
//
//            // Dot
//            let dotRadius: CGFloat = 4
//            let dot = UIBezierPath(
//                ovalIn: CGRect(
//                    x: p.x - dotRadius,
//                    y: p.y - dotRadius,
//                    width: dotRadius * 2,
//                    height: dotRadius * 2
//                )
//            )
//            UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1).setFill()
//            dot.fill()
//
//            // SMART LABEL POSITIONING
//            let unit = metric == .weight ? "kg" : "ft"
//            let labelText = "\(String(format: "%.1f", selected.value)) \(unit)"
//
//            var labelY = p.y - 18
//
//            // Avoid top edge
//            if labelY < padding {
//                labelY = p.y + 12
//            }
//
//            // Avoid optimal label collision
//            if let optimal = metric == .weight
//                ? optimalWeightByMonth[childAgeInMonths]
//                : optimalHeightByMonth[childAgeInMonths] {
//
//                let ratio = (optimal - paddedMin) / (paddedMax - paddedMin)
//                let optimalY = rect.height - padding -
//                               CGFloat(ratio) * (rect.height - 2 * padding)
//
//                if abs(labelY - optimalY) < minLabelSpacing {
//                    labelY = optimalY + minLabelSpacing
//                }
//            }
//
//            labelText.draw(
//                at: CGPoint(x: p.x + 6, y: labelY),
//                withAttributes: [
//                    .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
//                    .foregroundColor: UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
//                ]
//            )
//        }
//
//        
//        // MARK: - Y AXIS LABELS (kg / cm)
//        let unit = metric == .weight ? "kg" : "ft"
//
//        let labelAttrs: [NSAttributedString.Key: Any] = [
//            .font: UIFont.systemFont(ofSize: 11),
//            .foregroundColor: UIColor.secondaryLabel
//        ]
//
//        let steps = 4
//        let valueStep = (paddedMax - paddedMin) / Double(steps)
//
//        for i in 0...steps {
//            let value = paddedMin + Double(i) * valueStep
//
//            let y = rect.height - padding
//                - CGFloat(i) * (rect.height - 2 * padding) / CGFloat(steps)
//
//            let text = "\(Int(value)) \(unit)"
//
//            text.draw(
//                at: CGPoint(x: 4, y: y - 8),
//                withAttributes: labelAttrs
//            )
//        }
//        
//        // MARK: - X AXIS LABELS (months)
//        let months = data.map { $0.month }
//
//        for month in months {
//            guard let item = data.first(where: { $0.month == month }) else { continue }
//            let p = point(for: item)
//
//            "\(month)m".draw(
//                at: CGPoint(x: p.x - 10, y: rect.height - padding + 6),
//                withAttributes: labelAttrs
//            )
//        }
//    }
    override func draw(_ rect: CGRect) {
        guard data.count >= 1,
              let context = UIGraphicsGetCurrentContext() else { return }
        
        if data.count == 1 {

            let single = data[0]

            let paddedMin = single.value - 2
            let paddedMax = single.value + 2

            let yRatio: CGFloat = 0.5
            let x = bounds.midX
            let y = rect.height - padding - yRatio * (rect.height - 2 * padding)

            let dot = UIBezierPath(
                ovalIn: CGRect(x: x - 6, y: y - 6, width: 12, height: 12)
            )
            UIColor.systemPink.setFill()
            dot.fill()

            // Draw baseline
            let line = UIBezierPath()
            line.move(to: CGPoint(x: padding, y: y))
            line.addLine(to: CGPoint(x: rect.width - padding, y: y))
            UIColor.systemGray4.setStroke()
            line.setLineDash([4,4], count: 2, phase: 0)
            line.stroke()

            return
        }


        context.clear(rect)

//        let values = data.map { $0.value }
//        let minVal = values.min()!
//        let maxVal = values.max()!
//
//        
//        let range = max(2, maxVal - minVal)
//        let paddedMin = minVal - range * 0.5
//        let paddedMax = maxVal + range * 0.5
        
        var values = data.map { $0.value }

        if let selected = selectedPoint {
            if let optimal = metric == .weight
                ? optimalWeightValue(for: selected.month)
                : optimalHeightValue(for: selected.month) {

                values.append(optimal)
            }
        }

        let minVal = values.min()!
        let maxVal = values.max()!

        let range = max(2, maxVal - minVal)
        let paddedMin = minVal - range * 0.3
        let paddedMax = maxVal + range * 0.3



        func point(for item: GrowthPoint) -> CGPoint {

            let minMonth = data.first!.month
            let maxMonth = data.last!.month

            let monthSpan = max(1, maxMonth - minMonth)

            let xRatio = CGFloat(item.month - minMonth) / CGFloat(monthSpan)

            let totalRange = max(1, paddedMax - paddedMin)
            let yRatio = CGFloat((item.value - paddedMin) / totalRange)

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
            let prev = points[i - 1]
            let current = points[i]
            
            let mid = CGPoint(
                x: (prev.x + current.x) / 2,
                y: (prev.y + current.y) / 2
            )
            
            curve.addQuadCurve(to: mid, controlPoint: prev)
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
            let optimal = metric == .weight
                    ? optimalWeightValue(for: selected.month)
                    : optimalHeightValue(for: selected.month)


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
                let unit = metric == .weight ? "kg" : "ft"
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
            let unit = metric == .weight ? "kg" : "ft"
            let labelText = "\(String(format: "%.1f", selected.value)) \(unit)"

            var labelY = p.y - 18

            // Avoid top edge
            if labelY < padding {
                labelY = p.y + 12
            }

            // Avoid optimal label collision
            if let optimal = metric == .weight
                ? optimalWeightValue(for: selected.month)
                : optimalHeightValue(for: selected.month) {

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
        let unit = metric == .weight ? "kg" : "ft"

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

    
    func optimalWeightValue(for month: Int) -> Double? {

        let table = childGender.lowercased() == "female"
            ? girlsWeight
            : boysWeight

        return nearestValue(from: table, month: month)
    }

    func optimalHeightValue(for month: Int) -> Double? {

        let table = childGender.lowercased() == "female"
            ? girlsHeight
            : boysHeight

        guard let cmValue = nearestValue(from: table, month: month) else {
            return nil
        }

        // Convert cm → ft
        let feetValue = cmValue / 30.48
        return feetValue
    }


    private func nearestValue(from table: [Int: Double], month: Int) -> Double? {

        let sortedKeys = table.keys.sorted()
        guard let closest = sortedKeys.min(by: {
            abs($0 - month) < abs($1 - month)
        }) else { return nil }

        return table[closest]
    }


}
