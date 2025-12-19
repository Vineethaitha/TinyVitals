//
//  MedicalSectionExtractor.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//
import Foundation

enum MedicalSectionExtractor {

    static func extractSections(from text: String) -> [String: String] {

        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        var sections: [String: String] = [:]
        var currentSection = "General"
        var buffer: [String] = []

        func flush() {
            if !buffer.isEmpty {
                sections[currentSection, default: ""]
                    += buffer.joined(separator: " ")
                buffer.removeAll()
            }
        }

        for line in lines {
            let lower = line.lowercased()

            if isSectionHeader(lower) {
                flush()
                currentSection = normalizedSectionName(from: lower)
            } else {
                buffer.append(line)
            }
        }

        flush()
        return sections
    }

    private static func isSectionHeader(_ text: String) -> Bool {
        let headers = [
            "diagnosis",
            "assessment",
            "impression",
            "prescription",
            "treatment",
            "visit info",
            "patient info",
            "findings"
        ]

        return headers.contains { text.contains($0) }
    }

    private static func normalizedSectionName(from text: String) -> String {
        if text.contains("diagnosis") { return "Diagnosis" }
        if text.contains("assessment") { return "Assessment" }
        if text.contains("impression") { return "Impression" }
        if text.contains("prescription") { return "Prescription" }
        if text.contains("treatment") { return "Treatment" }
        if text.contains("visit") { return "Visit Info" }
        if text.contains("patient") { return "Patient Info" }
        return "General"
    }
}
