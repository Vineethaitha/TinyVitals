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
        let recorded_at: Date
    }


    // MARK: - Save Growth Entry
    func addGrowthEntry(
        childId: UUID,
        metric: GrowthMetric,
        value: Double,
        recordedAt: Date = Date()
    ) async throws {

        let payload = GrowthInsertDTO(
            child_id: childId,
            metric_type: metric == .weight ? "weight" : "height",
            value: value,
            recorded_at: recordedAt
        )

        try await client
            .from("growth_logs")
            .insert(payload)
            .execute()
    }



    // MARK: - Fetch Growth History
//    func fetchGrowth(
//        childId: UUID,
//        metric: GrowthMetric
//    ) async throws -> [GrowthPoint] {
//        
//        struct GrowthDTO: Decodable {
//            let value: Double
//            let recorded_at: Date
//        }
//        
//        let rows: [GrowthDTO] = try await client
//            .from("growth_logs")
//            .select()
//            .eq("child_id", value: childId)
//            .eq("metric_type", value: metric == .weight ? "weight" : "height")
//            .order("recorded_at", ascending: true)
//            .execute()
//            .value
//        
//        // We use index as X progression (stable graph)
//        return rows.enumerated().map { index, row in
//            GrowthPoint(
//                month: index,
//                value: row.value
//            )
//        }
//    }
    func fetchGrowth(
        child: ChildProfile,
        metric: GrowthMetric
    ) async throws -> [GrowthPoint] {
        
        struct GrowthDTO: Decodable {
            let value: Double
            let recorded_at: Date
        }

        let rows: [GrowthDTO] = try await client
            .from("growth_logs")
            .select()
            .eq("child_id", value: child.id)
            .eq("metric_type", value: metric == .weight ? "weight" : "height")
            .order("recorded_at", ascending: true)
            .execute()
            .value
        
        var latestPerMonth: [Int: GrowthDTO] = [:]
        
        for row in rows {
            
            let month = Calendar.current.dateComponents(
                [.month],
                from: child.dob,
                to: row.recorded_at
            ).month ?? 0
            
            if let existing = latestPerMonth[month] {
                if row.recorded_at > existing.recorded_at {
                    latestPerMonth[month] = row
                }
            } else {
                latestPerMonth[month] = row
            }
        }
        
        let sortedMonths = latestPerMonth.keys.sorted()
        print("Growth points:", sortedMonths)

        return sortedMonths.compactMap { month -> GrowthPoint? in
            
            guard let entry = latestPerMonth[month] else { return nil }
            
            return GrowthPoint(
                month: month,
                value: entry.value,
                recordedAt: entry.recorded_at
            )
        }

    }
    
    func ensureBaselineExists(for child: ChildProfile) async throws {

        struct GrowthDTO: Decodable {
            let value: Double
            let recorded_at: Date
        }

        let rows: [GrowthDTO] = try await client
            .from("growth_logs")
            .select()
            .eq("child_id", value: child.id)
            .execute()
            .value

        // If any entry exists for month 0, do nothing
        let hasMonthZero = rows.contains { row in
            let month = Calendar.current.dateComponents(
                [.month],
                from: child.dob,
                to: row.recorded_at
            ).month ?? 0
            return month == 0
        }

        if hasMonthZero { return }

        let baselineDate = Calendar.current.startOfDay(for: child.dob)

        // Insert birth weight at DOB
        if let birthWeight = child.weight {
            try await addGrowthEntry(
                childId: child.id,
                metric: .weight,
                value: birthWeight,
                recordedAt: baselineDate
            )
        }

        // Insert birth height at DOB
        if let birthHeight = child.height {
            try await addGrowthEntry(
                childId: child.id,
                metric: .height,
                value: birthHeight,
                recordedAt: baselineDate
            )
        }

    }


}
