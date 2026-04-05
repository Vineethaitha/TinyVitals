//
//  ChildMilestoneDTO.swift
//  TinyVitals
//

import Foundation

struct ChildMilestoneDTO: Codable {
    let id: UUID?
    let child_id: UUID
    let milestone_title: String
    let achieved_at: Date
    let created_at: Date?
    let video_path: String?
}
