//
//  RecordTextExtractor.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

import UIKit
import Vision
import PDFKit

enum RecordTextExtractor {

    static func extract(from record: MedicalFile) -> String {

        let text: String

        if let pdfURL = record.pdfURL {
            text = extractFromPDF(pdfURL)
        } else if let image = record.thumbnail {
            text = extractFromImage(image)
        } else {
            text = ""
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    
    private static func preprocessImage(_ image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)!
        
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(1.3, forKey: kCIInputContrastKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)
        filter.setValue(0.1, forKey: kCIInputBrightnessKey)

        let context = CIContext()
        let output = filter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!

        return UIImage(cgImage: cgImage)
    }
    
//    static func extract(from url: URL) -> String {
//
//        let ext = url.pathExtension.lowercased()
//
//        if ext == "pdf" {
//            return extractFromPDF(url)
//        } else if ["jpg", "jpeg", "png"].contains(ext) {
//            return extractFromImage(url)
//        } else {
//            return ""
//        }
//    }
    
    static func extract(from url: URL) -> String {
        if url.pathExtension.lowercased() == "pdf" {
            return extractFromPDF(url).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if let image = UIImage(contentsOfFile: url.path) {
            return extractFromImage(image).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return ""
    }

    
}

private extension RecordTextExtractor {
    

    static func extractFromPDF(_ url: URL) -> String {

        guard let pdf = PDFDocument(url: url) else { return "" }

        var text = ""

        for i in 0..<pdf.pageCount {
            guard let page = pdf.page(at: i) else { continue }
            text += page.string ?? ""
            text += "\n"
        }

        return text
    }
}

private extension RecordTextExtractor {
    
    private static func extractFromImage(_ url: URL) -> String {

        guard let image = UIImage(contentsOfFile: url.path) else { return "" }
        return extractFromImage(image)
    }

    static func extractFromImage(_ image: UIImage) -> String {

        let processedImage = preprocessImage(image)

        guard let cgImage = processedImage.cgImage else { return "" }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"]
        request.minimumTextHeight = 0.02

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: cgImagePropertyOrientation(from: image.imageOrientation)
        )

        do {
            try handler.perform([request])
        } catch {
            return ""
        }

        let observations = request.results ?? []

        let text = observations
            .compactMap { $0.topCandidates(1).first }
            .filter { $0.confidence > 0.4 }   // ⬅️ confidence threshold
            .map { $0.string }
            .joined(separator: "\n")

        return text
    }

    
    private static func cgImagePropertyOrientation(
        from orientation: UIImage.Orientation
    ) -> CGImagePropertyOrientation {

        switch orientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }

}


