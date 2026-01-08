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

    private(set) var allVaccines: [VaccinationManagerViewController.VaccineItem] = []

    private init() {
        loadInitialVaccinesIfNeeded()
    }

    private func loadInitialVaccinesIfNeeded() {
        guard allVaccines.isEmpty else { return }

        let tempVC = VaccinationManagerViewController()
        allVaccines = tempVC.buildVaccines()
    }

    func update(_ vaccines: [VaccinationManagerViewController.VaccineItem]) {
        allVaccines = vaccines
    }
}


