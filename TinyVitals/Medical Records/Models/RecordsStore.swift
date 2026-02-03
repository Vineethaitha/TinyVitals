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

    var foldersByChild: [UUID: [RecordFolder]] = [:]
    var filesByChild: [UUID: [MedicalFile]] = [:]

    func folders(for childId: UUID) -> [RecordFolder] {
        foldersByChild[childId] ?? []
    }

    func files(for childId: UUID, folderName: String) -> [MedicalFile] {
        filesByChild[childId]?.filter { $0.folderName == folderName } ?? []
    }

    func allFiles(for childId: UUID) -> [MedicalFile] {
        filesByChild[childId] ?? []
    }
}




