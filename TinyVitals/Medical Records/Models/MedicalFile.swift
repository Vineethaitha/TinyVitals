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
    let date: String
    let thumbnail: UIImage?
    let pdfURL: URL?
    var folderName: String
}











