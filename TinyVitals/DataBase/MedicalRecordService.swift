//
//  MedicalRecordService.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//

import Foundation
import Supabase
import UIKit

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

    func getSignedFileURL(path: String) async throws -> URL {
        let result = try await client
            .storage
            .from("medical-records") // ✅ FIXED
            .createSignedURL(
                path: path,
                expiresIn: 3600
            )

        return result
    }

    func downloadFile(from url: URL, fileType: String) async throws -> URL {
        let (data, _) = try await URLSession.shared.data(from: url)

        let ext: String
        switch fileType.lowercased() {
        case "pdf":
            ext = "pdf"
        case "image", "jpg", "jpeg", "png":
            ext = "jpg"
        default:
            ext = "dat"
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)

        try data.write(to: tempURL)
        return tempURL
    }

    func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)

        guard let image = UIImage(data: data) else {
            throw NSError(domain: "ImageDecodeError", code: 0)
        }
        return image
    }

}
