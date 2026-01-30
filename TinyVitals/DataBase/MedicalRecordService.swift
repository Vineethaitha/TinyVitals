//
//  MedicalRecordService.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import Foundation
import Supabase

final class MedicalRecordService {

    static let shared = MedicalRecordService()
    private init() {}

    private let client = SupabaseAuthService.shared.client

    // ➕ ADD RECORD
    func addRecord(_ record: MedicalRecordDTO) async throws {
        try await client
            .from("medical_records")
            .insert(record)
            .execute()
    }

    // 📥 FETCH RECORDS FOR CHILD
    func fetchRecords(childId: UUID) async throws -> [MedicalRecordDTO] {
        try await client
            .from("medical_records")
            .select()
            .eq("child_id", value: childId)
            .order("visit_date", ascending: false)
            .execute()
            .value
    }

    // 🗑 DELETE RECORD
    func deleteRecord(id: UUID) async throws {
        try await client
            .from("medical_records")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // 🗑 DELETE ALL RECORDS IN A FOLDER
    func deleteRecordsInFolder(childId: UUID, folderName: String) async throws {
        try await client
            .from("medical_records")
            .delete()
            .eq("child_id", value: childId)
            .eq("folder_name", value: folderName)
            .execute()
    }

}
