//
//  RecordFolder.swift
//  MedicalRecords_Feat
//
//  Created by admin0 on 12/12/25.
//

import Foundation
import UIKit


struct RecordFolder {
    var name: String
    var icon: UIImage?
    var color: UIColor = UIColor.randomIOSFolderColor()
}

extension UIColor {

    static let iosFolderColors: [UIColor] = [
        UIColor(hex: "#5DA9FF"), // iOS Blue
        UIColor(hex: "#72D572"), // iOS Green
        UIColor(hex: "#FFB770"), // iOS Orange
        UIColor(hex: "#FF8BA7"), // iOS Pink
        UIColor(hex: "#C9A7FF"), // iOS Purple
        UIColor(hex: "#4DC8C8")  // iOS Teal
    ]

    static func randomIOSFolderColor() -> UIColor {
        return iosFolderColors.randomElement()!
    }
}



extension UIColor {
    convenience init(hex: String) {
        var cleanHex = hex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgb)

        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}





