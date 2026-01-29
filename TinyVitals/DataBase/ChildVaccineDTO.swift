//
//  ChildVaccineDTO.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import Foundation

struct ChildVaccineDTO: Decodable {
    let id: UUID
    let child_id: UUID
    let vaccine_id: UUID
    let due_date: Date
    let taken: Bool
    let taken_on: Date?
}
