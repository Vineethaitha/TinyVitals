//
//  SymptomsPDFExporter.swift
//  TinyVitalsSymptomsTracker
//

import UIKit

final class SymptomsPDFExporter {

    static func generatePDF(
        from entries: [SymptomEntry],
        calendar: Calendar,
        childName: String,
        fromDate: Date,
        toDate: Date
    ) -> URL? {

        // Setup page size and context
        let pageSize = CGSize(width: 595, height: 842) // A4
        let margins = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        let usableWidth = pageSize.width - margins.left - margins.right
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(childName)_Symptoms.pdf")
        
        // Group entries by date
        var grouped: [Date: [SymptomEntry]] = [:]
        for entry in entries {
            let startOfDay = calendar.startOfDay(for: entry.date)
            grouped[startOfDay, default: []].append(entry)
        }
        
        // Sort
        let sortedDates = grouped.keys.sorted()
        
        do {
            try renderer.writePDF(to: url) { context in
                
                var currentY: CGFloat = margins.top
                func checkPageBreak(requiredSpace: CGFloat) {
                    if currentY + requiredSpace > pageSize.height - margins.bottom {
                        context.beginPage()
                        currentY = margins.top
                    }
                }
                
                context.beginPage()
                
                // Draw Header
                let titleDesc = UIFont.systemFont(ofSize: 24, weight: .bold).fontDescriptor.withDesign(.rounded)!
                let titleFont = UIFont(descriptor: titleDesc, size: 28)
                let titleString = "\(childName)'s Symptoms Report"
                
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor.label
                ]
                
                titleString.draw(at: CGPoint(x: margins.left, y: currentY), withAttributes: titleAttributes)
                currentY += 35
                
                // Draw Date Range
                let df = DateFormatter()
                df.dateStyle = .medium
                df.timeStyle = .none
                let rangeString = "From: \(df.string(from: fromDate))   To: \(df.string(from: toDate))"
                let rangeAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                rangeString.draw(at: CGPoint(x: margins.left, y: currentY), withAttributes: rangeAttributes)
                currentY += 40
                
                // Draw items
                for date in sortedDates {
                    checkPageBreak(requiredSpace: 60)
                    
                    // Draw Date Header
                    df.dateStyle = .full
                    let dateStr = df.string(from: date)
                    let dateAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                        .foregroundColor: UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1) // brandPink
                    ]
                    
                    dateStr.draw(at: CGPoint(x: margins.left, y: currentY), withAttributes: dateAttributes)
                    currentY += 30
                    
                    let dayEntries = grouped[date]!.sorted(by: { $0.date > $1.date })
                    
                    for entry in dayEntries {
                        // Time & Symptom Title
                        let tf = DateFormatter()
                        tf.timeStyle = .short
                        let timeStr = tf.string(from: entry.date)
                        
                        let titleStr = "• \(timeStr) — \(entry.symptom.title)"
                        let itemTitleAttr: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                            .foregroundColor: UIColor.label
                        ]
                        
                        checkPageBreak(requiredSpace: 80)
                        
                        titleStr.draw(at: CGPoint(x: margins.left, y: currentY), withAttributes: itemTitleAttr)
                        currentY += 24
                        
                        // Metadata lines
                        let metaFont = UIFont.systemFont(ofSize: 13, weight: .regular)
                        let metaAttr: [NSAttributedString.Key: Any] = [.font: metaFont, .foregroundColor: UIColor.secondaryLabel]
                        
                        if let temp = entry.temperature {
                            "Temperature: \(temp) °F".draw(at: CGPoint(x: margins.left + 20, y: currentY), withAttributes: metaAttr)
                            currentY += 18
                        }
                        if let weight = entry.weight {
                            "Weight: \(weight) kg".draw(at: CGPoint(x: margins.left + 20, y: currentY), withAttributes: metaAttr)
                            currentY += 18
                        }
                        if let height = entry.height {
                            "Height: \(height) ft".draw(at: CGPoint(x: margins.left + 20, y: currentY), withAttributes: metaAttr)
                            currentY += 18
                        }
                        if let severity = entry.severity {
                            "Severity: \(Int(severity))/10".draw(at: CGPoint(x: margins.left + 20, y: currentY), withAttributes: metaAttr)
                            currentY += 18
                        }
                        
                        // Notes wrapping
                        if let notes = entry.notes, !notes.isEmpty {
                            let noteStr = "Notes: \(notes)"
                            let noteRect = noteStr.boundingRect(
                                with: CGSize(width: usableWidth - 20, height: .greatestFiniteMagnitude),
                                options: .usesLineFragmentOrigin,
                                attributes: metaAttr,
                                context: nil
                            )
                            checkPageBreak(requiredSpace: noteRect.height + 20)
                            noteStr.draw(in: CGRect(x: margins.left + 20, y: currentY, width: usableWidth - 20, height: noteRect.height), withAttributes: metaAttr)
                            currentY += noteRect.height + 8
                        }
                        
                        // Optional Image
                        if let img = entry.image {
                            let maxImgWidth = usableWidth - 20
                            let maxImgHeight: CGFloat = 200
                            let aspect = img.size.width / img.size.height
                            
                            var targetSize = CGSize(width: maxImgWidth, height: maxImgWidth / aspect)
                            if targetSize.height > maxImgHeight {
                                targetSize.height = maxImgHeight
                                targetSize.width = maxImgHeight * aspect
                            }
                            
                            checkPageBreak(requiredSpace: targetSize.height + 30)
                            
                            let imgRect = CGRect(x: margins.left + 20, y: currentY, width: targetSize.width, height: targetSize.height)
                            // Draw image with rounded corners
                            let path = UIBezierPath(roundedRect: imgRect, cornerRadius: 8)
                            context.cgContext.saveGState()
                            path.addClip()
                            img.draw(in: imgRect)
                            context.cgContext.restoreGState()
                            
                            currentY += targetSize.height + 16
                        }
                        
                        currentY += 20 // Space between entries
                    }
                    
                    // Line separator
                    currentY += 10
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: margins.left, y: currentY))
                    linePath.addLine(to: CGPoint(x: pageSize.width - margins.right, y: currentY))
                    linePath.lineWidth = 0.5
                    UIColor.separator.setStroke()
                    linePath.stroke()
                    currentY += 20
                }
            }
            return url
        } catch {
            return nil
        }
    }
}
