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
            created_at: nil,
            video_path: nil
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

    // MARK: - Video Upload

    /// Uploads video data to Supabase Storage and returns the storage path.
    func uploadVideo(childId: UUID, title: String, videoData: Data) async throws -> String {
        let sanitized = title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "-")
            .lowercased()
        let path = "\(childId.uuidString)/\(sanitized).mp4"

        try await client
            .storage
            .from("milestone-videos")
            .upload(
                path,
                data: videoData,
                options: FileOptions(
                    contentType: "video/mp4",
                    upsert: true
                )
            )

        return path
    }

    // MARK: - Update video_path in DB

    func updateVideoPath(childId: UUID, title: String, videoPath: String?) async throws {
        struct VideoPathUpdate: Codable {
            let video_path: String?
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                if let path = video_path {
                    try container.encode(path, forKey: .video_path)
                } else {
                    try container.encodeNil(forKey: .video_path)
                }
            }
            enum CodingKeys: String, CodingKey { case video_path }
        }

        try await client
            .from("child_milestones")
            .update(VideoPathUpdate(video_path: videoPath))
            .eq("child_id", value: childId)
            .eq("milestone_title", value: title)
            .execute()
    }

    // MARK: - Get signed URL for video playback

    func getSignedVideoURL(path: String) async throws -> URL {
        try await client
            .storage
            .from("milestone-videos")
            .createSignedURL(
                path: path,
                expiresIn: 3600
            )
    }

    // MARK: - Delete video from storage

    func deleteVideo(path: String) async throws {
        try await client
            .storage
            .from("milestone-videos")
            .remove(paths: [path])
    }
}
