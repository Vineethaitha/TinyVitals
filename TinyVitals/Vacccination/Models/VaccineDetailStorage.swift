//
//  VaccineDetailStorage.swift
//  TinyVitals
//
//  Created by admin0 on 1/14/26.
//

import Foundation


struct VaccineDetailStorage: Codable {
    let date: Date
    let notes: String?
    let imageData: Data?
}
