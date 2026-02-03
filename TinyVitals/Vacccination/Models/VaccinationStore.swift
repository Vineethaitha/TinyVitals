//
//  VaccinationStore.swift
//  TinyVitals
//
//  Created by admin0 on 1/8/26.
//

import Foundation
import UIKit

final class VaccinationStore {

    static let shared = VaccinationStore()
    private init() {}

    private var vaccinesByChild: [String: [VaccineItem]] = [:]

    func vaccines(for childId: String) -> [VaccineItem] {
        vaccinesByChild[childId] ?? []
    }

    func setVaccines(_ vaccines: [VaccineItem], for childId: String) {
        vaccinesByChild[childId] = vaccines
    }

    func ensureVaccinesExist(
        for child: ChildProfile,
        builder: (Date) -> [VaccineItem]
    ) {
        let key = child.id.uuidString

        if vaccinesByChild[key] == nil {
            vaccinesByChild[key] = builder(child.dob)
        }
    }

}




