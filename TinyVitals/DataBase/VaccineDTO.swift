//
//  VaccineDTO.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import Foundation

struct VaccineDTO: Decodable {
    let id: UUID
    let name: String
    let description: String?
    let due_after_days: Int
}
