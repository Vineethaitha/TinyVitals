//
//  MedicalRecordMapper.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import UIKit

extension MedicalFile {

    init(dto: MedicalRecordDTO) {
        self.id = dto.id.uuidString
        self.childId = dto.child_id
        self.title = dto.title
        self.hospital = dto.hospital
        self.date = dto.visit_date
        self.folderName = dto.folder_name
        self.thumbnail = nil
        self.pdfURL = nil
    }
}
