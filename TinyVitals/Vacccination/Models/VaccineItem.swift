//
//  VaccineItem.swift
//  TinyVitals
//
//  Created by admin0 on 1/19/26.
//

import Foundation


struct VaccineItem: Identifiable, Codable {

    let id: String
    let name: String
    let description: String
    let ageGroup: String

    var status: VaccineStatus
    var date: Date

    // ✅ NEW
    var notes: String?
    var photoURL: String?

    init(
        id: String,
        name: String,
        description: String,
        ageGroup: String,
        status: VaccineStatus,
        date: Date,
        notes: String? = nil,
        photoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.ageGroup = ageGroup
        self.status = status
        self.date = date
        self.notes = notes
        self.photoURL = photoURL
    }
}


enum VaccineStatus: String, Codable {
    case upcoming
    case completed
    case skipped
    case rescheduled
}

