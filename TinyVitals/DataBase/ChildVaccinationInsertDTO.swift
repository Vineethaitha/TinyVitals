//
//  ChildVaccinationInsertDTO.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import Foundation

struct ChildVaccinationInsertDTO: Encodable {
    let child_id: UUID
    let vaccine_id: UUID
    let due_date: Date
}
