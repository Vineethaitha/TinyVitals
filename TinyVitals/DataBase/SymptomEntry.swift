//
//  SymptomEntry.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import UIKit

struct SymptomEntry {
    let id: UUID
    let symptom: SymptomItem
    let date: Date

    let height: Double?
    let weight: Double?
    let temperature: Double?
    let severity: Double?

    let notes: String?
    let imagePath: String?   // ✅ ADD THIS
    var image: UIImage?      // loaded lazily
}
