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

    // Single source of truth
    private(set) var timelineDataByDate: [Date: [SymptomTimelineItem]] = [:]

    func addSymptoms(
        _ items: [SymptomTimelineItem],
        on date: Date
    ) {
        let day = calendar.startOfDay(for: date)
        timelineDataByDate[day, default: []].append(contentsOf: items)
    }

    func symptoms(for date: Date) -> [SymptomTimelineItem] {
        let day = calendar.startOfDay(for: date)
        return timelineDataByDate[day] ?? []
    }

    func allDates() -> [Date] {
        timelineDataByDate.keys.sorted()
    }

    func hasSymptoms(on date: Date) -> Bool {
        let day = calendar.startOfDay(for: date)
        return timelineDataByDate[day] != nil
    }
}
