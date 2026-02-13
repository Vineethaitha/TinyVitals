//
//  ChildProfile.swift
//  ChildProfile
//
//  Created by admin0 on 12/21/25.
//

import Foundation

struct ChildProfile: Identifiable, Codable, Equatable {

    let id: UUID
    var name: String
    var dob: Date
    var gender: String
    var bloodGroup: String
    var weight: Double?
    var height: Double?
    var photoFilename: String?

    // MARK: - Helpers

    var ageString: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month],
            from: dob,
            to: Date()
        )

        let years = components.year ?? 0
        let months = components.month ?? 0

        if years == 0 {
            return "\(months) month\(months == 1 ? "" : "s")"
        } else {
            return "\(years) yr \(months) mo"
        }
    }
}

