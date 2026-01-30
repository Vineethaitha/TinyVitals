//
//  RecordFolderDTO.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import Foundation

struct RecordFolderDTO: Codable {
    let id: UUID?
    let child_id: UUID
    let name: String
    let created_at: Date?
}
