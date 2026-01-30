//
//  RecordFolderService.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import Foundation
import Supabase

final class RecordFolderService {

    static let shared = RecordFolderService()
    private init() {}

    // ✅ THIS WAS MISSING
    private let client = SupabaseAuthService.shared.client

    // 📥 FETCH FOLDERS
    func fetchFolders(childId: UUID) async throws -> [RecordFolderDTO] {
        try await client
            .from("record_folders")
            .select()
            .eq("child_id", value: childId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    // ➕ CREATE SINGLE FOLDER
    func createFolder(childId: UUID, name: String) async throws {
        let dto = RecordFolderDTO(
            id: nil,
            child_id: childId,
            name: name,
            created_at: nil
        )

        try await client
            .from("record_folders")
            .insert(dto)
            .execute()
    }

    // 🧠 CREATE DEFAULT FOLDERS (ONCE)
    func createDefaultFoldersIfNeeded(childId: UUID) async throws {

        // ✅ fetchFolders NOW EXISTS
        let existing = try await fetchFolders(childId: childId)
        guard existing.isEmpty else { return }

        let defaults = ["Reports", "Prescriptions", "Vaccinations"]

        for name in defaults {
            try await createFolder(childId: childId, name: name)
        }
    }
    
    // ✏️ RENAME FOLDER
    func renameFolder(
        childId: UUID,
        oldName: String,
        newName: String
    ) async throws {

        // 1️⃣ Update folder name
        try await client
            .from("record_folders")
            .update(["name": newName])
            .eq("child_id", value: childId)
            .eq("name", value: oldName)
            .execute()

        // 2️⃣ Update all records under that folder
        try await client
            .from("medical_records")
            .update(["folder_name": newName])
            .eq("child_id", value: childId)
            .eq("folder_name", value: oldName)
            .execute()
    }
    
    // 🗑 DELETE FOLDER
    func deleteFolder(childId: UUID, name: String) async throws {
        try await client
            .from("record_folders")
            .delete()
            .eq("child_id", value: childId)
            .eq("name", value: name)
            .execute()
    }


}
