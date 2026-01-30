//
//  SymptomItem+Lookup.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import UIKit

extension SymptomItem {

    /// Returns a SymptomItem matching a title from DB
    /// Falls back safely if not found
    static func item(for title: String) -> SymptomItem {

        return allItems.first {
            $0.title.lowercased() == title.lowercased()
        }
        ?? SymptomItem(
            title: title,
            iconName: "stethoscope",
            tintColor: .systemPink
        )
    }

    /// SINGLE source of truth for symptoms
    static let allItems: [SymptomItem] = [
        SymptomItem(title: "Fever", iconName: "thermometer", tintColor: .systemRed),
        SymptomItem(title: "Cold", iconName: "wind", tintColor: .systemBlue),
        SymptomItem(title: "Cough", iconName: "lungs", tintColor: .systemTeal),
        SymptomItem(title: "Headache", iconName: "brain", tintColor: .systemPurple),
        SymptomItem(title: "Vomiting", iconName: "cross.case", tintColor: .systemOrange),
        SymptomItem(title: "Diarrhea", iconName: "drop", tintColor: .systemIndigo),
        SymptomItem(title: "Fatigue", iconName: "battery.25", tintColor: .systemYellow),
        SymptomItem(title: "Stomach Pain", iconName: "stethoscope", tintColor: .systemPink)
    ]
}
