//
//  VaccinationStatusUpdateDTO.swift
//  TinyVitals
//
//  Created by user66 on 13/02/26.
//

import Foundation

struct VaccinationStatusUpdateDTO: Encodable {
    let status: String
    let taken: Bool
    let taken_on: Date?
}
