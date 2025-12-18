//
//  RecordsStore.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/14/25.
//

import Foundation

final class RecordsStore {

    static let shared = RecordsStore()
    private init() {}

    var folders: [RecordFolder] = []
    var filesByFolder: [String: [MedicalFile]] = [:]

    var allRecords: [MedicalFile] {
        filesByFolder.values.flatMap { $0 }
    }
}

