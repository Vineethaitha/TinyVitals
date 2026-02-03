//  MedicalSectionParser.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

import Foundation

enum MedicalSectionParser {

    // MARK: - Section Priority (lower = more important)
    private static let sectionPriority: [String: Int] = [
        "Diagnosis": 0,
        "Assessment": 0,
        "Impression": 0,
        "Chief Complaints": 0,
        "Symptoms": 0,
        "Imaging": 0,
        "Investigation": 0,
        "Vitals": 0,
        "Treatment": 0,
        "Medications": 0,
        "Prescription": 0,
        "Plan": 9,
        "Progress": 9,
        "Hospital": 50,
        "Discharge": 8,
        "Allergy Details": 0,
        "Physical Examination": 5,
        "Overview": 0
    ]

    // MARK: - Main Parser
    static func parse(from text: String) -> [MedicalSection] {

        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        var sections: [MedicalSection] = []
        var currentTitle = "Overview"
        var currentItems: [String] = []

        for line in lines {

            if isSectionHeader(line) {

                if !currentItems.isEmpty {
                    sections.append(
                        MedicalSection(
                            title: currentTitle,
                            items: currentItems
                        )
                    )
                }

                currentTitle = normalizeHeader(line)
                currentItems = []

            } else {
                currentItems.append(clean(line))
            }
        }

        if !currentItems.isEmpty {
            sections.append(
                MedicalSection(
                    title: currentTitle,
                    items: currentItems
                )
            )
        }

        return sections.sorted { a, b in
            let p1 = sectionPriority[a.title] ?? 99
            let p2 = sectionPriority[b.title] ?? 99
            return p1 < p2
        }
    }
}

// MARK: - Helpers
private extension MedicalSectionParser {

    static func isSectionHeader(_ line: String) -> Bool {
        if line.hasSuffix(":") {
            return true
        }

        let letters = line.filter { $0.isLetter }
        if !letters.isEmpty {
            let uppercaseRatio =
                Double(letters.filter { $0.isUppercase }.count) /
                Double(letters.count)

            if uppercaseRatio > 0.65 {
                return true
            }
        }
        let keywords = [
            "diagnosis",
            "assessment",
            "impression",
            "hospital course",
            "history",
            "chief complaint",
            "symptoms",
            "vitals",
            "investigation",
            "imaging",
            "treatment",
            "medications",
            "prescription",
            "plan",
            "progress",
            "discharge"
        ]

        let lower = line.lowercased()
        return keywords.contains { lower.contains($0) }
    }

    static func normalizeHeader(_ line: String) -> String {
        line
            .replacingOccurrences(of: ":", with: "")
            .capitalized
    }

    static func clean(_ line: String) -> String {
        line
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)
    }
}
