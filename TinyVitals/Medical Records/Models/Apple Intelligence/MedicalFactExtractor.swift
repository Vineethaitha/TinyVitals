//
//  MedicalFactExtractor.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

import Foundation

enum MedicalFactExtractor {

    static func extract(from text: String) -> MedicalSummary {

        let lower = text.lowercased()

        return MedicalSummary(
            diagnosis: extractDiagnosis(from: lower),
            symptoms: extractSymptoms(from: lower),
            vitals: extractVitals(from: lower),
            treatment: extractTreatment(from: lower),
            imaging: extractImaging(from: lower),
            progress: extractProgress(from: lower)
        )
    }
}

private extension MedicalFactExtractor {

    static func extractDiagnosis(from text: String) -> [String] {
        var results: [String] = []

        if text.contains("hemorrhagic stroke") {
            results.append("Acute hemorrhagic stroke")
        }
        if text.contains("thalamic") {
            results.append("Right thalamic involvement")
        }
        if text.contains("hemiplegia") {
            results.append("Left-sided hemiplegia")
        }
        if text.contains("gcs") {
            results.append("Disturbed level of consciousness")
        }

        return results
    }

    static func extractSymptoms(from text: String) -> [String] {
        var results: [String] = []

        if text.contains("weakness") {
            results.append("Sudden onset limb weakness")
        }
        if text.contains("vomiting") {
            results.append("Vomiting")
        }
        if text.contains("confused") {
            results.append("Confusion")
        }
        if text.contains("headache") {
            results.append("Headache")
        }

        return results
    }

    static func extractVitals(from text: String) -> [String] {
        var results: [String] = []

        if let bp = match(text, pattern: #"bp[:\s]*\d+/\d+"#) {
            results.append("Blood pressure: \(bp.uppercased())")
        }
        if let hr = match(text, pattern: #"hr[:\s]*\d+"#) {
            results.append("Heart rate: \(hr)")
        }
        if let temp = match(text, pattern: #"temp[:\s]*\d+°c"#) {
            results.append("Temperature: \(temp)")
        }

        return results
    }

    static func extractTreatment(from text: String) -> [String] {
        var results: [String] = []

        if text.contains("icu") {
            results.append("ICU admission")
        }
        if text.contains("oxygen") || text.contains("mask") {
            results.append("Oxygen support")
        }
        if text.contains("nipride") {
            results.append("Antihypertensive infusion (Nipride)")
        }
        if text.contains("lasix") {
            results.append("Diuretic therapy (Lasix)")
        }

        return results
    }

    static func extractImaging(from text: String) -> [String] {
        var results: [String] = []

        if text.contains("ct brain") {
            results.append("CT brain performed")
        }
        if text.contains("hemorrhage") {
            results.append("Acute intracranial hemorrhage detected")
        }

        return results
    }

    static func extractProgress(from text: String) -> [String] {
        var results: [String] = []

        if text.contains("improved") {
            results.append("Partial improvement noted")
        }
        if text.contains("subsided") {
            results.append("Symptoms subsided")
        }

        return results
    }

    static func match(_ text: String, pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(text.startIndex..., in: text)
        if let match = regex?.firstMatch(in: text, range: range),
           let r = Range(match.range, in: text) {
            return String(text[r])
        }
        return nil
    }
}

