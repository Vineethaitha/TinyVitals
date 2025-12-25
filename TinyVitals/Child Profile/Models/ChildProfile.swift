//
//  ChildProfile.swift
//  ChildProfile
//
//  Created by admin0 on 12/21/25.
//

import Foundation

//struct ChildProfile {
//    let name: String
//    let dob: Date
//    let gender: String
//    let bloodGroup: String
//    let weight: Double?
//    let height: Double?
//}

struct ChildProfile {
    let id: UUID
    var name: String
    var dob: Date
    var gender: String
    var bloodGroup: String
    var weight: Double?
    var height: Double?
    var photoFilename: String?
}
