//
//  SymptomsPDFExporter.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 26/12/25.
//

import UIKit

final class SymptomsPDFExporter {

    static func generatePDF(
        from data: [Date: [SymptomTimelineItem]],
        calendar: Calendar
    ) -> URL? {

        let pageSize = CGSize(width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Symptoms_History.pdf")

        do {
            try renderer.writePDF(to: url) { context in

                let sortedDates = data.keys.sorted()

                for date in sortedDates {
                    context.beginPage()

                    let titleAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 20)
                    ]

                    let bodyAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14)
                    ]

                    var y: CGFloat = 40

                    let formatter = DateFormatter()
                    formatter.dateStyle = .full

                    let dateText = formatter.string(from: date)
                    dateText.draw(at: CGPoint(x: 40, y: y), withAttributes: titleAttributes)

                    y += 40

                    guard let items = data[date] else { continue }

                    for item in items {
                        let line = "• \(item.time)  \(item.title) – \(item.description)"
                        line.draw(
                            at: CGPoint(x: 40, y: y),
                            withAttributes: bodyAttributes
                        )
                        y += 22
                    }
                }
            }

            return url
        } catch {
            print("PDF generation failed:", error)
            return nil
        }
    }
}
