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
    
    func generateVaccinesForChild(
        childId: UUID,
        dob: Date
    ) async throws {
        
        let vaccines: [VaccineDTO] = try await client
            .from("vaccines_master")
            .select()
            .execute()
            .value
        
        let records: [ChildVaccinationInsertDTO] = vaccines.map { vaccine in
            ChildVaccinationInsertDTO(
                child_id: childId,
                vaccine_id: vaccine.id,
                due_date: Calendar.current.date(
                    byAdding: .day,
                    value: vaccine.due_after_days,
                    to: dob
                )!
            )
        }
        
        try await client
            .from("child_vaccinations")
            .insert(records)
            .select()   // 🔥 THIS LINE FIXES PGRST100
            .execute()
    }
}
