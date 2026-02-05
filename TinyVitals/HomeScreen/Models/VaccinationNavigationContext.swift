//
//  VaccinationNavigationContext.swift
//  TinyVitals
//
//  Created by admin0 on 2/4/26.
//

import Foundation
import UIKit

final class VaccinationNavigationContext {
    static let shared = VaccinationNavigationContext()
    private init() {}
    
    var pendingAgeGroup: String?
}
