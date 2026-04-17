//
//  RecordSummarizer.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

//import NaturalLanguage
//
//enum RecordSummarizer {
//
//    static func summarize(text: String) -> String {
//
//        let summary = MedicalFactExtractor.extract(from: text)
//
//        guard !summary.isEmpty else {
//            return "No structured medical information could be extracted."
//        }
//
//        var output: [String] = []
//
//        if !summary.diagnosis.isEmpty {
//            output.append("🧠 Diagnosis\n" + bullets(summary.diagnosis))
//        }
//
//        if !summary.symptoms.isEmpty {
//            output.append("📋 Symptoms\n" + bullets(summary.symptoms))
//        }
//
//        if !summary.imaging.isEmpty {
//            output.append("🧪 Imaging\n" + bullets(summary.imaging))
//        }
//
//        if !summary.vitals.isEmpty {
//            output.append("❤️ Vitals\n" + bullets(summary.vitals))
//        }
//
//        if !summary.treatment.isEmpty {
//            output.append("💊 Treatment\n" + bullets(summary.treatment))
//        }
//
//        if !summary.progress.isEmpty {
//            output.append("📈 Progress\n" + bullets(summary.progress))
//        }
//
//        return output.joined(separator: "\n\n")
//    }
//
//    private static func bullets(_ items: [String]) -> String {
//        items.map { "• \($0)" }.joined(separator: "\n")
//    }
//}
//
//
//

//import Foundation
//
//enum RecordSummarizer {
//
//    static func summarize(text: String) -> [MedicalSection] {
//        MedicalSectionParser.parse(from: text)
//    }
//}


//
//  RecordSummarizer.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif


enum RecordSummarizer {

    // MARK: - Section Priority (must match parser logic)
    private static let sectionPriority: [String: Int] = [
        "Diagnosis": 0,
        "Assessment": 1,
        "Impression": 1,
        "Chief Complaint": 2,
        "Symptoms": 2,
        "Imaging": 3,
        "Investigation": 3,
        "Vitals": 4,
        "Treatment": 5,
        "Medications": 5,
        "Prescription": 5,
        "Plan": 6,
        "Progress": 7,
        "Hospital Course": 7,
        "Discharge": 8,
        "Overview": 50
    ]

    // MARK: - Async Public API (FoundationModels)
    static func summarizeAsync(text: String) async -> [MedicalSection] {
        if #available(iOS 18.0, *) {
            #if canImport(FoundationModels)
            do {
                let prompt = """
                You are an expert pediatrician assistant.
                Please extract the following medical topics from the raw text into a standard layout:
                Diagnosis, Symptoms, Vitals, Medications, Plan.
                Medical Document Text: \(text)
                """
                
                let session = LanguageModelSession()
                let response = try await session.respond(to: prompt)
                
                // response is typically of type Response<String>. We extract the actual .content.
                // If .content doesn't exist on some betas, we use mirror reflection as a fallback wrapper-stripper.
                var generatedText = ""
                let mirror = Mirror(reflecting: response)
                for child in mirror.children {
                    if let stringVal = child.value as? String, (child.label == "content" || child.label == "text" || child.label == "value") {
                        generatedText = stringVal
                        break
                    }
                }
                
                // Ultimate fallback: direct typecast or string stripping
                if generatedText.isEmpty {
                    if let text = response as? String {
                        generatedText = text
                    } else {
                        // Stripping Response<String>(...)
                        let raw = "\(response)"
                        generatedText = raw.replacingOccurrences(of: "Response<String>(", with: "")
                    }
                }
                
                var sections = parseRawResponse(generatedText)
//                sections.append(MedicalSection(title: "Overview", items: ["✨ Summarized securely on-device using Apple Intelligence."]))
                return sections
                
            } catch {
                return summarizeSync(text: text)
            }
            #else
            return summarizeSync(text: text)
            #endif
        } else {
            return summarizeSync(text: text)
        }
    }

    // MARK: - Sync Public API (Legacy Fallback)
    static func summarizeSync(text: String) -> [MedicalSection] {
        var sections = parseRawResponse(text)
//        sections.append(MedicalSection(title: "Overview", items: ["🔍 Extracted using standard local OCR."]))
        return sections
    }

    // MARK: - Core Parser
    private static func parseRawResponse(_ text: String) -> [MedicalSection] {

        let parsedSections = MedicalSectionParser.parse(from: text)

        var merged: [String: [String]] = [:]

        for section in parsedSections {
            let normalizedTitle: String

            // Merge related medical meanings
            switch section.title {
            case "Assessment", "Impression":
                normalizedTitle = "Diagnosis"
            case "Hospital Course":
                normalizedTitle = "Progress"
            default:
                normalizedTitle = section.title
            }

            merged[normalizedTitle, default: []]
                .append(contentsOf: section.items)
        }

        // Convert to ordered MedicalSection list
        let result = merged
            .map { title, items in
                MedicalSection(
                    title: title,
                    items: removeDuplicatesPreservingOrder(items)
                )
            }
            .sorted {
                let p1 = sectionPriority[$0.title] ?? 99
                let p2 = sectionPriority[$1.title] ?? 99
                return p1 < p2
            }

        return result
    }

    // MARK: - Helpers
    private static func removeDuplicatesPreservingOrder(_ items: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for item in items {
            if seen.insert(item).inserted {
                result.append(item)
            }
        }
        return result
    }
}

