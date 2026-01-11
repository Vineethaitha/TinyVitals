//
//  SymptomEntry.swift
//  TinyVitals
//
//  Created by user66 on 11/01/26.
//

import UIKit

struct SymptomEntry: Identifiable {

    let id: UUID
    let symptom: SymptomItem
    let date: Date

    var height: Double?
    var weight: Double?
    var temperature: Double?
    var severity: Double?
    var notes: String?
    var image: UIImage?

    init(
        symptom: SymptomItem,
        date: Date
    ) {
        self.id = UUID()
        self.symptom = symptom
        self.date = date
    }
}
