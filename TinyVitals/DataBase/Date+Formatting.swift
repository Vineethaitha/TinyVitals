//
//  Date+Formatting.swift
//  TinyVitals
//
//  Created by user66 on 31/01/26.
//

import Foundation

extension Date {

    func toSearchableString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }

}
