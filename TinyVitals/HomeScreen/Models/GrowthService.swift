//
//  GrowthService.swift
//  TinyVitals
//
//  Created by user66 on 18/02/26.
//

import Foundation
import Supabase

final class GrowthService {
    
    static let shared = GrowthService()
    private init() {}
    
    private let client = SupabaseAuthService.shared.client
    
    // MARK: - Insert DTO
    struct GrowthInsertDTO: Encodable {
        let child_id: UUID
        let metric_type: String
        let value: Double
    }

    // MARK: - Save Growth Entry
    func addGrowthEntry(
        childId: UUID,
        metric: GrowthMetric,
        value: Double
    ) async throws {

        let payload = GrowthInsertDTO(
            child_id: childId,
            metric_type: metric == .weight ? "weight" : "height",
            value: value
        )

        try await client
            .from("growth_logs")
            .insert(payload)
            .execute()
    }

    // MARK: - Fetch Growth History
    func fetchGrowth(
        childId: UUID,
        metric: GrowthMetric
    ) async throws -> [GrowthPoint] {
        
        struct GrowthDTO: Decodable {
            let value: Double
            let recorded_at: Date
        }
        
        let rows: [GrowthDTO] = try await client
            .from("growth_logs")
            .select()
            .eq("child_id", value: childId)
            .eq("metric_type", value: metric == .weight ? "weight" : "height")
            .order("recorded_at", ascending: true)
            .execute()
            .value
        
        // We use index as X progression (stable graph)
        return rows.enumerated().map { index, row in
            GrowthPoint(
                month: index,
                value: row.value
            )
        }
    }
}
