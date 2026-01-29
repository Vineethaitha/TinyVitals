//
//  ChildMapper.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import Foundation

extension ChildProfile {
    init(dto: ChildDTO) {
        self.id = dto.id ?? UUID()
        self.name = dto.name
        self.dob = dto.dob
        self.gender = dto.gender ?? ""
        self.bloodGroup = ""          // fill later if added to DB
        self.weight = nil
        self.height = nil
        self.photoFilename = nil
    }
}
