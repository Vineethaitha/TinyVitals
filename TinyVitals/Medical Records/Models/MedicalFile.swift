//
//  MedicalRecord.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/12/25.
//

import UIKit
import Foundation

struct MedicalFile {
    let id: String
    let childId: UUID
    let title: String
    let hospital: String
    let date: Date
    let folderName: String

    let filePath: String
    let fileType: String

    var thumbnail: UIImage?
    var pdfURL: URL?
}










