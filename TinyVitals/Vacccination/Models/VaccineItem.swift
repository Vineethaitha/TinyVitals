//
//  VaccineItem.swift
//  TinyVitals
//
//  Created by admin0 on 1/19/26.
//

import Foundation


struct VaccineItem: Identifiable, Codable {

    let id: String              // 🔥 stable ID
    let name: String
    let description: String
    let ageGroup: String
    var status: VaccineStatus
    let date: Date
}

enum VaccineStatus: String, Codable {
    case upcoming
    case completed
    case skipped
    case rescheduled
}

