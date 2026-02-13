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

    // MARK: - Generate vaccine schedule for child

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
            
            let due = Calendar.current.date(
                byAdding: .day,
                value: vaccine.due_after_days,
                to: dob
            )!
            
            return ChildVaccinationInsert(
                child_id: childId,
                vaccine_id: vaccine.id,
                due_date: formatter.string(from: due)
            )
        }
        
        try await client
            .from("child_vaccinations")
            .insert(records)
            .execute()
    }

    // MARK: - Fetch vaccines for UI

    func fetchVaccines(childId: UUID) async throws -> [VaccineItem] {

        let rows: [ChildVaccinationDTO] = try await client
            .from("child_vaccinations")
            .select("""
                *,
                vaccines_master(*)
            """)
            .eq("child_id", value: childId)
            .execute()
            .value

        return rows.map {
            VaccineItem(
                id: $0.id.uuidString,
                name: $0.vaccines_master.name,
                description: $0.vaccines_master.description ?? "",
                ageGroup: "",
                status: VaccineStatus(rawValue: $0.status) ?? .upcoming,
                date: $0.taken_on ?? $0.due_date,
                notes: $0.notes,
                photoURL: $0.photo_path
            )
        }
    }

    // MARK: - Update status

    func updateVaccinationStatus(
        recordId: UUID,
        status: VaccineStatus
    ) async throws {

        let payload = VaccinationStatusUpdateDTO(
            status: status.rawValue,
            taken: status == .completed,
            taken_on: status == .completed ? Date() : nil
        )

        try await client
            .from("child_vaccinations")
            .update(payload)
            .eq("id", value: recordId)
            .execute()
    }
    
    func updateVaccinationFull(
        recordId: UUID,
        status: VaccineStatus,
        takenOn: Date?,
        notes: String?,
        photoPath: String?
    ) async throws {

        struct Payload: Encodable {
            let status: String
            let taken: Bool
            let taken_on: Date?
            let notes: String?
            let photo_path: String?
        }

        let payload = Payload(
            status: status.rawValue,
            taken: status == .completed,
            taken_on: takenOn,
            notes: notes,
            photo_path: photoPath
        )

        try await client
            .from("child_vaccinations")
            .update(payload)
            .eq("id", value: recordId)
            .execute()
    }

    func uploadVaccinePhoto(
        imageData: Data,
        recordId: UUID
    ) async throws -> String {

        let path = "\(recordId).jpg"

        try await client.storage
            .from("vaccine-images")
            .upload(
                path: path,
                file: imageData,
                options: FileOptions(contentType: "image/jpeg")
            )

        let url = try client.storage
            .from("vaccine-images")
            .getPublicURL(path: path)

        return url.absoluteString
    }


}
