//
//  RecordsStore.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/14/25.
//

//import Foundation

//final class RecordsStore {
//
//    static let shared = RecordsStore()
//    private init() {}
//
//    var folders: [RecordFolder] = []
//    var filesByFolder: [String: [MedicalFile]] = [:]
//
//    var allRecords: [MedicalFile] {
//        filesByFolder.values.flatMap { $0 }
//    }
//}

import Foundation
import UIKit

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
    
    func updateFiles(_ files: [MedicalFile], for childId: UUID, folderName: String) {
        guard var all = filesByChild[childId] else { return }

        all.removeAll { $0.folderName == folderName }
        all.append(contentsOf: files)

        filesByChild[childId] = all
    }
    
    func replaceFiles(_ files: [MedicalFile], for childId: UUID) {
        filesByChild[childId] = files
    }
    
    func ensureDefaultFolders(for childId: UUID) {
        if foldersByChild[childId] == nil {
            foldersByChild[childId] = [
                RecordFolder(name: "Reports", icon: UIImage(systemName: "folder.fill")),
                RecordFolder(name: "Prescriptions", icon: UIImage(systemName: "pills.fill")),
                RecordFolder(name: "Vaccinations", icon: UIImage(systemName: "bandage.fill"))
            ]
            filesByChild[childId] = []
        }
    }

}




