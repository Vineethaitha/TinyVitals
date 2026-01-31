//
//  MedicalRecordMapper.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import UIKit

extension MedicalFile {

    init(dto: MedicalRecordDTO) {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        self.id = dto.id.uuidString
        self.childId = dto.child_id
        self.title = dto.title
        self.hospital = dto.hospital
        self.date = formatter.date(from: dto.visit_date) ?? Date()
        self.folderName = dto.folder_name
        self.filePath = dto.file_path
        self.fileType = dto.file_type
        self.thumbnail = nil
        self.pdfURL = nil
    }
}
