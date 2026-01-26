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

    private let storageKeyPrefix = "vaccines_"

    // MARK: - Public API

    func vaccines(for childId: String) -> [VaccineItem] {
        load(childId: childId)
    }

    func setVaccines(_ vaccines: [VaccineItem], for childId: String) {
        save(vaccines, childId: childId)
    }

    // ENSURE INITIAL DATA (called once per child)
    func ensureVaccinesExist(
        for child: ChildProfile,
        builder: (Date) -> [VaccineItem]
    ) -> [VaccineItem] {

        let key = child.id.uuidString
        let existing = load(childId: key)

        if !existing.isEmpty {
            return existing
        }

        let generated = builder(child.dob)
        save(generated, childId: key)
        return generated
    }

    // MARK: - Persistence

    private func save(_ vaccines: [VaccineItem], childId: String) {
        let key = storageKeyPrefix + childId
        if let data = try? JSONEncoder().encode(vaccines) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load(childId: String) -> [VaccineItem] {
        let key = storageKeyPrefix + childId
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let vaccines = try? JSONDecoder().decode([VaccineItem].self, from: data)
        else {
            return []
        }
        return vaccines
    }
}





