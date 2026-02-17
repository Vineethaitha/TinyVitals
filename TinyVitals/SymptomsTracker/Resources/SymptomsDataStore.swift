//
//  SymptomsDataStore.swift
//  TinyVitals
//
//  Created by user66 on 10/01/26.
//


import Foundation

final class SymptomsDataStore {

    static let shared = SymptomsDataStore()
    private init() {}

    private let calendar = Calendar.current

    private(set) var entriesByChild: [String: [Date: [SymptomEntry]]] = [:]

    func addEntry(_ entry: SymptomEntry, for childId: String) {
        let day = calendar.startOfDay(for: entry.date)
        entriesByChild[childId, default: [:]][day, default: []].append(entry)
    }


    func entries(for date: Date, childId: String) -> [SymptomEntry] {
        let day = calendar.startOfDay(for: date)
        return entriesByChild[childId]?[day] ?? []
    }


    func deleteEntry(_ entry: SymptomEntry, childId: String) {
        let day = calendar.startOfDay(for: entry.date)

        entriesByChild[childId]?[day]?.removeAll { $0.id == entry.id }

        // ✅ CLEAN UP EMPTY DAY
        if entriesByChild[childId]?[day]?.isEmpty == true {
            entriesByChild[childId]?.removeValue(forKey: day)
        }

        // ✅ CLEAN UP EMPTY CHILD
        if entriesByChild[childId]?.isEmpty == true {
            entriesByChild.removeValue(forKey: childId)
        }
    }



    func hasSymptoms(on date: Date, childId: String) -> Bool {
        let day = calendar.startOfDay(for: date)
        return !(entriesByChild[childId]?[day]?.isEmpty ?? true)
    }


    func allDates(for childId: String) -> [Date] {
        entriesByChild[childId]?.keys.sorted() ?? []
    }
    
    func clearEntries(for childId: String) {
        entriesByChild[childId] = [:]
    }


}
