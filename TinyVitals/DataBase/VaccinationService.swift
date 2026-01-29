//
//  VaccinationService.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import Foundation
import Supabase

final class VaccinationService {
    
    static let shared = VaccinationService()
    private init() {}
    
    private let client = SupabaseAuthService.shared.client
    
    private func isoDate(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: date)
    }
    
    func generateVaccinesForChild(
        childId: UUID,
        dob: Date
    ) async throws {
        
        let vaccines: [VaccineDTO] = try await client
            .from("vaccines_master")
            .select()
            .execute()
            .value
        
        let formatter = ISO8601DateFormatter()
        
        let records = vaccines.map { vaccine in
            ChildVaccinationInsert(
                child_id: childId,
                vaccine_id: vaccine.id,
                due_date: formatter.string(
                    from: Calendar.current.date(
                        byAdding: .day,
                        value: vaccine.due_after_days,
                        to: dob
                    )!
                )
            )
        }
        
        try await client
            .from("child_vaccinations")
            .insert(records)
            .execute()
    }
}
