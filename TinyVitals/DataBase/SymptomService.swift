//
//  SymptomService.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import Foundation
import Supabase

final class SymptomService {

    static let shared = SymptomService()
    private init() {}

    private let client = SupabaseAuthService.shared.client

    // SAVE
    func addSymptom(_ dto: SymptomLogDTO) async throws {
        try await client
            .from("symptom_logs")
            .insert(dto)
            .execute()
    }

    // FETCH
    func fetchSymptoms(childId: UUID) async throws -> [SymptomLogDTO] {
        try await client
            .from("symptom_logs")
            .select()
            .eq("child_id", value: childId)
            .order("logged_at", ascending: false)
            .execute()
            .value
    }

    // DELETE
    func deleteSymptom(id: UUID) async throws {
        try await client
            .from("symptom_logs")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    // SIGNED IMAGE URL
    func signedImageURL(path: String) async throws -> URL {
        try await client.storage
            .from("symptom-images")
            .createSignedURL(path: path, expiresIn: 3600)
    }
}
