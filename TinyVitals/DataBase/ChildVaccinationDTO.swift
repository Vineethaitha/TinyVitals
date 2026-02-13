//
//  ChildVaccinationDTO.swift
//  TinyVitals
//
//  Created by user66 on 13/02/26.
//

import Foundation

struct ChildVaccinationDTO: Decodable {
    let id: UUID
    let child_id: UUID
    let vaccine_id: UUID
    let due_date: Date
    let taken: Bool
    let taken_on: Date?
    let status: String
    let notes: String?
    let photo_path: String?
    let vaccines_master: VaccineDTO
    
}
