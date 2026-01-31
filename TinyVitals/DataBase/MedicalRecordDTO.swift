//
//  MedicalRecordDTO.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import Foundation

struct MedicalRecordDTO: Codable {
    let id: UUID
    let child_id: UUID
    let title: String
    let hospital: String
    let visit_date: String   // ✅ FIX
    let folder_name: String
    let file_path: String
    let file_type: String
    let created_at: Date?
}
