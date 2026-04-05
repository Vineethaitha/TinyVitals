//
//  MilestoneTrackingService.swift
//  TinyVitals
//

import Foundation
import Supabase

final class MilestoneTrackingService {

    static let shared = MilestoneTrackingService()
    private init() {}

    private var client: SupabaseClient {
        SupabaseAuthService.shared.client
    }

    // MARK: - Fetch achieved milestones for a child

    func fetchAchieved(childId: UUID) async throws -> [ChildMilestoneDTO] {
        try await client
            .from("child_milestones")
            .select()
            .eq("child_id", value: childId)
            .execute()
            .value
    }

    // MARK: - Mark a milestone as achieved

    func markAchieved(childId: UUID, title: String, achievedAt: Date) async throws {
        let dto = ChildMilestoneDTO(
            id: nil,
            child_id: childId,
            milestone_title: title,
            achieved_at: achievedAt,
            created_at: nil
        )

        try await client
            .from("child_milestones")
            .upsert(dto)
            .execute()
    }

    // MARK: - Unmark a milestone (delete)

    func unmarkAchieved(childId: UUID, title: String) async throws {
        try await client
            .from("child_milestones")
            .delete()
            .eq("child_id", value: childId)
            .eq("milestone_title", value: title)
            .execute()
    }
}
