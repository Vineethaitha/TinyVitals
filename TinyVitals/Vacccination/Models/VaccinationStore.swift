//
//  VaccinationStore.swift
//  TinyVitals
//
//  Created by admin0 on 1/8/26.
//

import Foundation
import UIKit

//final class VaccinationStore {
//
//    static let shared = VaccinationStore()
//
//    private(set) var allVaccines: [VaccinationManagerViewController.VaccineItem] = []
//
//    private init() {
//        loadInitialVaccinesIfNeeded()
//    }
//
//    private func loadInitialVaccinesIfNeeded() {
//        guard allVaccines.isEmpty else { return }
//
//        let tempVC = VaccinationManagerViewController()
//        allVaccines = tempVC.buildVaccines()
//    }
//
//    func update(_ vaccines: [VaccinationManagerViewController.VaccineItem]) {
//        allVaccines = vaccines
//    }
//}

//final class VaccinationStore {
//
//    static let shared = VaccinationStore()
//
//    private init() {}
//
//    private(set) var vaccinesByChild: [UUID: [VaccinationManagerViewController.VaccineItem]] = [:]
//
//    func vaccines(for childId: UUID) -> [VaccinationManagerViewController.VaccineItem] {
//        vaccinesByChild[childId] ?? []
//    }
//
//    func setVaccines(
//        _ vaccines: [VaccinationManagerViewController.VaccineItem],
//        for childId: UUID
//    ) {
//        vaccinesByChild[childId] = vaccines
//    }
//
//    func ensureVaccinesExist(
//        for child: ChildProfile,
//        builder: (Date) -> [VaccinationManagerViewController.VaccineItem]
//    ) {
//        guard vaccinesByChild[child.id] == nil else { return }
//        vaccinesByChild[child.id] = builder(child.dob)
//    }
//}


final class VaccinationStore {

    static let shared = VaccinationStore()
    private init() {}

    private var vaccinesByChild: [String: [VaccinationManagerViewController.VaccineItem]] = [:]

    // READ
    func vaccines(for childId: String) -> [VaccinationManagerViewController.VaccineItem] {
        vaccinesByChild[childId] ?? []
    }

    // WRITE
    func setVaccines(
        _ vaccines: [VaccinationManagerViewController.VaccineItem],
        for childId: String
    ) {
        vaccinesByChild[childId] = vaccines
    }

    // ENSURE INITIAL DATA
    func ensureVaccinesExist(
        for child: ChildProfile,
        builder: (Date) -> [VaccinationManagerViewController.VaccineItem]
    ) {
        let key = child.id.uuidString

        if vaccinesByChild[key] == nil {
            vaccinesByChild[key] = builder(child.dob)
        }
    }

}




