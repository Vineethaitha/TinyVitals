//
//  ChildDTO.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import Foundation

struct ChildDTO: Codable {
    let id: UUID?
    let user_id: UUID
    let name: String
    let dob: Date
    let gender: String?

    let blood_group: String?
    let weight: Double?
    let height: Double?
    let photo_filename: String?
}
