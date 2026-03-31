//
//  Milestone.swift
//  TinyVitals
//
//  Developmental milestones based on WHO/CDC standards.
//

import UIKit

// MARK: - Category

enum MilestoneCategory: String {
    case motor     = "Motor"
    case social    = "Social"
    case language  = "Language"
    case cognitive = "Cognitive"

    var color: UIColor {
        switch self {
        case .motor:     return .systemGreen
        case .social:    return UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
        case .language:  return UIColor(red: 112/255, green: 210/255, blue: 237/255, alpha: 1)
        case .cognitive: return .systemPurple
        }
    }

    var icon: String {
        switch self {
        case .motor:     return "figure.walk"
        case .social:    return "heart.circle.fill"
        case .language:  return "text.bubble.fill"
        case .cognitive: return "lightbulb.fill"
        }
    }
}

// MARK: - Model

struct Milestone {
    let title: String
    let description: String
    let category: MilestoneCategory
    let ageMonths: Int
}

// MARK: - Snapshot

struct MilestoneSnapshot {
    let previous: Milestone?
    let current: Milestone?
    let next: Milestone?
    let achievedCount: Int
    let totalCount: Int
    let progress: Double
}

// MARK: - Service

struct MilestoneService {

    static let milestones: [Milestone] = [
        Milestone(title: "Lifts Head",             description: "Briefly lifts head during tummy time",            category: .motor,     ageMonths: 1),
        Milestone(title: "Social Smile",            description: "Smiles at people spontaneously",                 category: .social,    ageMonths: 2),
        Milestone(title: "Tracks Objects",          description: "Follows moving objects with eyes smoothly",       category: .cognitive, ageMonths: 3),
        Milestone(title: "Holds Head Steady",       description: "Holds head steady without support",              category: .motor,     ageMonths: 4),
        Milestone(title: "First Laughs",            description: "Laughs out loud and squeals with delight",        category: .social,    ageMonths: 4),
        Milestone(title: "Sits Without Support",    description: "Sits up independently for short periods",         category: .motor,     ageMonths: 6),
        Milestone(title: "Babbles",                 description: "Makes consonant sounds like 'ba' and 'da'",       category: .language,  ageMonths: 6),
        Milestone(title: "Crawls",                  description: "Moves around by crawling on hands and knees",     category: .motor,     ageMonths: 9),
        Milestone(title: "Responds to Name",        description: "Turns and looks when you call their name",        category: .social,    ageMonths: 9),
        Milestone(title: "First Words",             description: "Says 'mama' or 'dada' with meaning",             category: .language,  ageMonths: 12),
        Milestone(title: "Pulls to Stand",          description: "Pulls up to standing using furniture",            category: .motor,     ageMonths: 12),
        Milestone(title: "Walks Independently",     description: "Takes several steps without any support",         category: .motor,     ageMonths: 15),
        Milestone(title: "Runs",                    description: "Runs with increasing coordination",              category: .motor,     ageMonths: 18),
        Milestone(title: "Uses 10+ Words",          description: "Has a vocabulary of at least 10 words",           category: .language,  ageMonths: 18),
        Milestone(title: "Two-Word Phrases",        description: "Combines words like 'more milk'",                 category: .language,  ageMonths: 24),
        Milestone(title: "Kicks Ball",              description: "Kicks a ball forward with coordination",          category: .motor,     ageMonths: 24),
        Milestone(title: "Speaks in Sentences",     description: "Uses 3–4 word sentences fluently",                category: .language,  ageMonths: 36),
        Milestone(title: "Pedals Tricycle",         description: "Rides a tricycle using pedals independently",     category: .motor,     ageMonths: 36),
        Milestone(title: "Tells Stories",           description: "Tells simple stories from memory",                category: .language,  ageMonths: 48),
        Milestone(title: "Hops on One Foot",        description: "Can hop on one foot several times",               category: .motor,     ageMonths: 48),
        Milestone(title: "Writes Letters",          description: "Prints some letters and numbers",                 category: .cognitive, ageMonths: 60),
        Milestone(title: "Skips",                   description: "Can skip and hop with coordination",              category: .motor,     ageMonths: 60),
    ]

    static func ageInMonths(from dob: Date) -> Int {
        max(Calendar.current.dateComponents([.month], from: dob, to: Date()).month ?? 0, 0)
    }

    static func snapshot(for dob: Date) -> MilestoneSnapshot {
        let age = ageInMonths(from: dob)
        var prev: Milestone?
        var curr: Milestone?
        var next: Milestone?
        var achieved = 0

        for (i, m) in milestones.enumerated() {
            if m.ageMonths <= age {
                achieved += 1
                prev = m
            } else if curr == nil {
                curr = m
                if i + 1 < milestones.count { next = milestones[i + 1] }
            }
        }

        // All achieved
        if curr == nil, let last = milestones.last {
            curr = last
            prev = milestones.count >= 2 ? milestones[milestones.count - 2] : nil
            achieved = milestones.count
        }

        let progress = milestones.isEmpty ? 0 : Double(achieved) / Double(milestones.count)
        return MilestoneSnapshot(previous: prev, current: curr, next: next,
                                 achievedCount: achieved, totalCount: milestones.count,
                                 progress: progress)
    }
}
