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

    // MARK: - Update DTO
    struct GrowthUpdateDTO: Encodable {
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

        let calendar = Calendar.current
        
        // Start of month
        let monthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: recordedAt)
        )!
        
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        struct ExistingGrowthDTO: Decodable {
            let id: UUID
            let recorded_at: Date
        }

        // 1️⃣ Check if an entry exists for this child + metric in this month
        let existing: [ExistingGrowthDTO] = try await client
            .from("growth_logs")
            .select("id, recorded_at")
            .eq("child_id", value: childId)
            .eq("metric_type", value: metric == .weight ? "weight" : "height")
            .gte("recorded_at", value: monthStart.ISO8601Format())
            .lt("recorded_at", value: nextMonth.ISO8601Format())
            .execute()
            .value

        if let row = existing.first {
            
            // 2️⃣ Update existing monthly entry
            let updatePayload = GrowthUpdateDTO(
                value: value,
                recorded_at: recordedAt
            )

            try await client
                .from("growth_logs")
                .update(updatePayload)
                .eq("id", value: row.id)
                .execute()

        } else {
            
            // 3️⃣ Insert new monthly entry
            let insertPayload = GrowthInsertDTO(
                child_id: childId,
                metric_type: metric == .weight ? "weight" : "height",
                value: value,
                recorded_at: recordedAt
            )

            try await client
                .from("growth_logs")
                .insert(insertPayload)
                .execute()
        }
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
            
            let start = Calendar.current.startOfDay(for: child.dob)
            let end = Calendar.current.startOfDay(for: row.recorded_at)

            let month = max(
                0,
                Calendar.current.dateComponents(
                    [.month],
                    from: start,
                    to: end
                ).month ?? 0
            )
            
            
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
    
//    func ensureBaselineExists(for child: ChildProfile) async throws {
//
//        struct GrowthDTO: Decodable {
//            let metric_type: String
//            let recorded_at: Date
//        }
//
//        let rows: [GrowthDTO] = try await client
//            .from("growth_logs")
//            .select("metric_type, recorded_at")
//            .eq("child_id", value: child.id)
//            .execute()
//            .value
//
//        let start = Calendar.current.startOfDay(for: child.dob)
//
//        var hasWeightBaseline = false
//        var hasHeightBaseline = false
//
//        for row in rows {
//            let end = Calendar.current.startOfDay(for: row.recorded_at)
//
//            let month = Calendar.current.dateComponents(
//                [.month],
//                from: start,
//                to: end
//            ).month ?? 0
//
//            if month == 0 {
//                if row.metric_type == "weight" {
//                    hasWeightBaseline = true
//                }
//                if row.metric_type == "height" {
//                    hasHeightBaseline = true
//                }
//            }
//        }
//
//        let baselineDate = start
//
//        if !hasWeightBaseline, let birthWeight = child.weight {
//            try await addGrowthEntry(
//                childId: child.id,
//                metric: .weight,
//                value: birthWeight,
//                recordedAt: baselineDate
//            )
//        }
//
//        if !hasHeightBaseline, let birthHeight = child.height {
//            try await addGrowthEntry(
//                childId: child.id,
//                metric: .height,
//                value: birthHeight,
//                recordedAt: baselineDate
//            )
//        }
//    }


}
