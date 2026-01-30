//
//  Supabase_db.swift
//  TinyVitals
//
//  Created by user66 on 30/01/26.
//


//import Supabase
//import Foundation
//import UIKit
//
//final class Supabase_db {
//
//    static let shared = Supabase_db()
//    private init() {}
//
//    private let client = SupabaseManager.shared.client
//
//    // FETCH
//    func fetchRecords(childId: UUID) async throws -> [MedicalRecordDTO] {
//        try await client
//            .from("medical_records")
//            .select()
//            .eq("child_id", value: childId.uuidString)
//            .order("visit_date", ascending: false)
//            .execute()
//            .value
//    }
//
//    // INSERT
//    func addRecord(_ dto: MedicalRecordDTO) async throws {
//        try await client
//            .from("medical_records")
//            .insert(dto)
//            .execute()
//    }
//
//    // DELETE
//    func deleteRecord(id: UUID) async throws {
//        try await client
//            .from("medical_records")
//            .delete()
//            .eq("id", value: id.uuidString)
//            .execute()
//    }
//}
//
//
