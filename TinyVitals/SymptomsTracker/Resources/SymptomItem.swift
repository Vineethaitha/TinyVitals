//
//  SymptomItem.swift
//  TinyVitalsSymptomsTracker
//
//  Created by user66 on 30/12/25.
//

import UIKit

struct SymptomItem: Hashable {
    let title: String
    let iconName: String
    let tintColor: UIColor
}

extension UIColor {
    static func from(string: String) -> UIColor {
        switch string.lowercased() {
        case "systemred": return .systemRed
        case "systemblue": return .systemBlue
        case "systemteal": return .systemTeal
        case "systempurple": return .systemPurple
        case "systemorange": return .systemOrange
        case "systemindigo": return .systemIndigo
        case "systemyellow": return .systemYellow
        case "systempink": return .systemPink
        case "systemcyan": return .systemCyan
        case "systembrown": return .systemBrown
        case "systemmint": return .systemMint
        case "systemgray": return .systemGray
        case "systemgreen": return .systemGreen
        default:
            // Fallback for hex string if used
            if string.hasPrefix("#") {
                return UIColor(hex: string) ?? .systemGray
            }
            return .systemGray
        }
    }
    
    // Simple hex initializer in case users use hex strings
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let length = hexSanitized.count
        guard length == 6 else { return nil }

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
