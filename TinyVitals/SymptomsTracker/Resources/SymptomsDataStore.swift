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

    private(set) var entriesByDate: [Date: [SymptomEntry]] = [:]

    func addEntry(_ entry: SymptomEntry) {
        let day = calendar.startOfDay(for: entry.date)
        entriesByDate[day, default: []].append(entry)
    }

    func entries(for date: Date) -> [SymptomEntry] {
        let day = calendar.startOfDay(for: date)
        return entriesByDate[day] ?? []
    }

    func deleteEntry(_ entry: SymptomEntry) {
        let day = calendar.startOfDay(for: entry.date)
        entriesByDate[day]?.removeAll { $0.id == entry.id }
    }

    func hasSymptoms(on date: Date) -> Bool {
        let day = calendar.startOfDay(for: date)
        return !(entriesByDate[day]?.isEmpty ?? true)
    }

    func allDates() -> [Date] {
        entriesByDate.keys.sorted()
    }
}
