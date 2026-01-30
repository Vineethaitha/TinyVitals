//
//  AIQueryParser.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

import Foundation
import NaturalLanguage

final class AIQueryParser {

    static func filter(
        records: [MedicalFile],
        prompt: String
    ) -> [MedicalFile] {

        let keywords = extractKeywords(from: prompt)
        let dateConstraint = extractDateConstraint(from: prompt)

        return records
            .map { record in
                (record, score(record, keywords: keywords, dateConstraint: dateConstraint))
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}



private extension AIQueryParser {

    static func extractKeywords(from text: String) -> [String] {

        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text.lowercased()

        var keywords: [String] = []

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, range in

            guard let tag else { return true }

            if tag == .noun || tag == .verb {
                keywords.append(String(text[range]).lowercased())
            }

            return true
        }

        return keywords
    }
}


private extension AIQueryParser {

    static func extractDateConstraint(from text: String) -> Date? {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = .current

        for month in formatter.monthSymbols {
            if text.lowercased().contains(month.lowercased()) {
                var comps = DateComponents()
                comps.month = formatter.monthSymbols.firstIndex(of: month)! + 1
                comps.year = Calendar.current.component(.year, from: Date())
                return Calendar.current.date(from: comps)
            }
        }

        return nil
    }
}


private extension AIQueryParser {

    static func score(
        _ record: MedicalFile,
        keywords: [String],
        dateConstraint: Date?
    ) -> Int {

        var score = 0

        let searchableText = (
            record.title + " " +
            record.hospital + " " +
            record.date.toSearchableString()
        ).lowercased()

        for keyword in keywords {
            if searchableText.contains(keyword) {
                score += 2
            }
        }

        if let date = dateConstraint,
           record.date >= date {
            score += 3
        }

        return score
    }
}
