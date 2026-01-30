//
//  SymptomLogDTO.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import Foundation

struct SymptomLogDTO: Codable {
    let id: UUID?
    let child_id: UUID
    let symptom_title: String
    let logged_at: Date

    let height: Double?
    let weight: Double?
    let temperature: Double?
    let severity: Int?

    let notes: String?
    let image_path: String?
}
