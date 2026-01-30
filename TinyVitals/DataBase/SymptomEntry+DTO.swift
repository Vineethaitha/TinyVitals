//
//  SymptomEntry+DTO.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import UIKit

extension SymptomEntry {

    init(dto: SymptomLogDTO) {

        self.id = dto.id ?? UUID()
        self.symptom = SymptomItem.item(for: dto.symptom_title)
        self.date = dto.logged_at

        self.height = dto.height
        self.weight = dto.weight
        self.temperature = dto.temperature
        self.severity = dto.severity.map { Double($0) }

        self.notes = dto.notes
        self.image = nil
    }
}
