//
//  SymptomMasterDTO.swift
//  TinyVitals
//
//  Created for fetching symptoms master.

import Foundation

struct SymptomMasterDTO: Codable {
    let id: UUID
    let title: String
    let iconName: String
    let tintColor: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case iconName = "icon_name"
        case tintColor = "tint_color"
    }
}
