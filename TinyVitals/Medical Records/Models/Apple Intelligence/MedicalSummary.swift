//
//  MedicalSummary.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/16/25.
//

import Foundation

struct MedicalSummary {

    let diagnosis: [String]
    let symptoms: [String]
    let vitals: [String]
    let treatment: [String]
    let imaging: [String]
    let progress: [String]

    var isEmpty: Bool {
        diagnosis.isEmpty &&
        symptoms.isEmpty &&
        vitals.isEmpty &&
        treatment.isEmpty &&
        imaging.isEmpty &&
        progress.isEmpty
    }
}
