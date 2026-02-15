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
    // MARK: - Age Group Calculator

    private func ageGroupForDate(dob: Date, due: Date) -> String {

        let c = Calendar.current
        let days = c.dateComponents([.day], from: dob, to: due).day ?? 0

        switch days {

        case 0...7:
            return "At Birth"

        case 35...49:
            return "6 Weeks"

        case 63...77:
            return "10 Weeks"

        case 91...105:
            return "14 Weeks"

        case 150...210:
            return "6 Months"

        case 240...300:
            return "9 Months"

        case 330...390:
            return "12 Months"

        case 420...480:
            return "15 Months"

        case 510...570:
            return "18 Months"

        case 700...900:
            return "2 Years"

        case 1700...2200:
            return "5–6 Years"

        case 3500...4500:
            return "10–12 Years"

        default:
            return "Other"
        }
    }

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

    func fetchVaccines(childId: UUID, dob: Date) async throws -> [VaccineItem] {

        let rows: [ChildVaccinationDTO] = try await client
            .from("child_vaccinations")
            .select("""
                *,
                vaccines_master(*)
            """)
            .eq("child_id", value: childId)
            .execute()
            .value

        return rows.map { row in

//            let finalDate = row.taken_on ?? row.due_date
//            let ageGroup = ageGroupForDate(dob: dob, due: finalDate)
            
            let ageGroup = ageGroupForDate(dob: dob, due: row.due_date)
            let displayDate = row.taken_on ?? row.due_date


            return VaccineItem(
                id: row.id.uuidString,
                name: row.vaccines_master.name,
                description: row.vaccines_master.description ?? "",
                ageGroup: ageGroup,
                status: VaccineStatus(rawValue: row.status) ?? .upcoming,
                date: displayDate,
                notes: row.notes,
                photoURL: row.photo_path
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
