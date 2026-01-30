//
//  SymptomItem+Lookup.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import UIKit

extension SymptomItem {

    /// Returns a SymptomItem matching a title from DB
    /// Falls back safely if not found
    static func item(for title: String) -> SymptomItem {

        return allItems.first {
            $0.title.lowercased() == title.lowercased()
        }
        ?? SymptomItem(
            title: title,
            iconName: "stethoscope",
            tintColor: .systemPink
        )
    }

    /// SINGLE source of truth for symptoms
    static let allItems: [SymptomItem] = [
        SymptomItem(title: "Fever", iconName: "thermometer", tintColor: .systemRed),
        SymptomItem(title: "Cold", iconName: "wind", tintColor: .systemBlue),
        SymptomItem(title: "Cough", iconName: "lungs", tintColor: .systemTeal),
        SymptomItem(title: "Headache", iconName: "brain", tintColor: .systemPurple),
        SymptomItem(title: "Vomiting", iconName: "cross.case", tintColor: .systemOrange),
        SymptomItem(title: "Diarrhea", iconName: "drop", tintColor: .systemIndigo),
        SymptomItem(title: "Fatigue", iconName: "battery.25", tintColor: .systemYellow),
        SymptomItem(title: "Stomach Pain", iconName: "stethoscope", tintColor: .systemPink),
        SymptomItem(title: "Breathing Issue", iconName: "wind.circle", tintColor: .systemCyan),
        SymptomItem(title: "Appetite loss", iconName: "fork.knife", tintColor: .systemBrown),
        SymptomItem(title: "Ear Pain", iconName: "ear", tintColor: .systemMint),
        SymptomItem(title: "Eye Redness", iconName: "eye", tintColor: .systemRed),
        SymptomItem(title: "Sore Throat", iconName: "mouth", tintColor: .systemPurple),
        SymptomItem(title: "Chest Pain", iconName: "heart", tintColor: .systemPink),
        SymptomItem(title: "Body Pain", iconName: "figure.walk", tintColor: .systemOrange),
        SymptomItem(title: "Sneezing", iconName: "nose", tintColor: .systemBlue),
        SymptomItem(title: "Sleep Issues", iconName: "bed.double", tintColor: .systemIndigo),
        SymptomItem(title: "Dizziness", iconName: "gyroscope", tintColor: .systemGray),
        SymptomItem(title: "Swelling", iconName: "bandage", tintColor: .systemGreen),
        SymptomItem(title: "Rash", iconName: "allergens", tintColor: .systemPink),
        SymptomItem(title: "High Fever", iconName: "thermometer.high", tintColor: .systemRed),
        SymptomItem(title: "Low Fever", iconName: "thermometer", tintColor: .systemOrange),
        SymptomItem(title: "Chills", iconName: "snowflake", tintColor: .systemBlue),
        SymptomItem(title: "Excess Crying", iconName: "speaker.wave.2", tintColor: .systemPink),
        SymptomItem(title: "Irritability", iconName: "face.smiling.inverse", tintColor: .systemPurple),
        SymptomItem(title: "Sleepiness", iconName: "bed.double", tintColor: .systemIndigo),
        SymptomItem(title: "Poor Sleep", iconName: "moon.zzz", tintColor: .systemGray),
        SymptomItem(title: "Spitting Up", iconName: "arrow.up.circle", tintColor: .systemOrange),
        SymptomItem(title: "Constipation", iconName: "circle.slash", tintColor: .systemBrown),
        SymptomItem(title: "Gas / Bloating", iconName: "cloud", tintColor: .systemTeal),
        SymptomItem(title: "Abdo Cramps", iconName: "waveform.path.ecg", tintColor: .systemPink),
        SymptomItem(title: "Nasal block", iconName: "nose", tintColor: .systemBlue),
        SymptomItem(title: "Wheezing", iconName: "wind", tintColor: .systemCyan),
        SymptomItem(title: "Fast Breathing", iconName: "lungs", tintColor: .systemRed),
        SymptomItem(title: "Diaper Rash", iconName: "drop.triangle", tintColor: .systemPink),
        SymptomItem(title: "Skin Redness", iconName: "hand.raised.fill", tintColor: .systemRed),
        SymptomItem(title: "Dry Skin", iconName: "sun.min", tintColor: .systemOrange),
        SymptomItem(title: "Hives", iconName: "exclamationmark.triangle", tintColor: .systemPurple),
        SymptomItem(title: "Teeth Pain", iconName: "mouth", tintColor: .systemIndigo),
        SymptomItem(title: "Poor Feeding", iconName: "fork.knife", tintColor: .systemGray),
        SymptomItem(title: "Drooling", iconName: "drop", tintColor: .systemBlue),
        SymptomItem(title: "Ear Tugging", iconName: "ear", tintColor: .systemOrange),
        SymptomItem(title: "Eye Discharge", iconName: "eye", tintColor: .systemRed),
        SymptomItem(title: "Frequent Bowel", iconName: "arrow.2.circlepath.circle", tintColor: .systemPink),
        SymptomItem(title: "Chills", iconName: "snow", tintColor: .systemBlue),
        // General
        SymptomItem(title: "Fussy", iconName: "face.smiling", tintColor: .systemPink),
        SymptomItem(title: "Crying", iconName: "speaker.wave.2", tintColor: .systemRed),
        SymptomItem(title: "Lethargy", iconName: "zzz", tintColor: .systemGray),
        SymptomItem(title: "Weakness", iconName: "figure.walk.circle", tintColor: .systemOrange),

        // Feeding
        SymptomItem(title: "Poor Feed", iconName: "fork.knife", tintColor: .systemBrown),
        SymptomItem(title: "Overfeed", iconName: "plus.circle", tintColor: .systemGreen),
        SymptomItem(title: "Spit Up", iconName: "arrow.up.circle", tintColor: .systemOrange),
        SymptomItem(title: "Choking", iconName: "exclamationmark.triangle", tintColor: .systemRed),

        // Digestive
        SymptomItem(title: "Bloating", iconName: "cloud", tintColor: .systemTeal),
        SymptomItem(title: "Gas", iconName: "wind", tintColor: .systemBlue),
        SymptomItem(title: "Hard Stool", iconName: "circle.fill", tintColor: .systemBrown),
        SymptomItem(title: "Loose Stool", iconName: "drop", tintColor: .systemIndigo),

        // Respiratory
        SymptomItem(title: "Fast Breath", iconName: "lungs", tintColor: .systemRed),
        SymptomItem(title: "Noisy Breath", iconName: "wind.circle", tintColor: .systemCyan),
        SymptomItem(title: "Chest Pull", iconName: "arrow.down.circle", tintColor: .systemOrange),
        SymptomItem(title: "Blue Lips", iconName: "mouth", tintColor: .systemBlue),

        // Skin
        SymptomItem(title: "Dry Skin", iconName: "sun.min", tintColor: .systemOrange),
        SymptomItem(title: "Itching", iconName: "hand.raised", tintColor: .systemPurple),
        SymptomItem(title: "Peeling", iconName: "square.split.2x2", tintColor: .systemGray),
        SymptomItem(title: "Spots", iconName: "circle.grid.cross", tintColor: .systemPink),

        // ENT
        SymptomItem(title: "Runny Nose", iconName: "nose", tintColor: .systemBlue),
        SymptomItem(title: "Blocked Nose", iconName: "nose.fill", tintColor: .systemGray),
        SymptomItem(title: "Hoarse Cry", iconName: "speaker.slash", tintColor: .systemOrange),
        SymptomItem(title: "Ear Fluid", iconName: "ear", tintColor: .systemMint),

        // Eyes
        SymptomItem(title: "Watery Eyes", iconName: "eye", tintColor: .systemBlue),
        SymptomItem(title: "Sticky Eyes", iconName: "eye.slash", tintColor: .systemOrange),
        SymptomItem(title: "Eye Swell", iconName: "eye.circle", tintColor: .systemRed),

        // Sleep
        SymptomItem(title: "No Sleep", iconName: "moon.zzz", tintColor: .systemGray),
        SymptomItem(title: "Night Cry", iconName: "moon", tintColor: .systemPurple),
        SymptomItem(title: "Restless", iconName: "bed.double", tintColor: .systemIndigo),

        // Mouth / Teeth
        SymptomItem(title: "Teething", iconName: "mouth", tintColor: .systemPink),
        SymptomItem(title: "Drool", iconName: "drop", tintColor: .systemBlue),
        SymptomItem(title: "Sore Gums", iconName: "mouth.fill", tintColor: .systemRed),

        // Urine / Diaper
        SymptomItem(title: "Less Urine", iconName: "drop.circle", tintColor: .systemOrange),
        SymptomItem(title: "Dark Urine", iconName: "drop.fill", tintColor: .systemBrown),
        SymptomItem(title: "Diaper Leak", iconName: "drop.triangle", tintColor: .systemPink),

        // Movement
        SymptomItem(title: "Stiff Body", iconName: "figure.stand", tintColor: .systemGray),
        SymptomItem(title: "Shaking", iconName: "waveform", tintColor: .systemRed),
        SymptomItem(title: "Twitching", iconName: "waveform.path", tintColor: .systemPurple)


    ]
}
