//
//  ChildService.swift
//  TinyVitals
//
//  Created by user66 on 29/01/26.
//

import Foundation
import Supabase

final class ChildService {

    static let shared = ChildService()
    private init() {}

    private let client = SupabaseAuthService.shared.client
    
    func fetchChildren(
        userId: UUID
    ) async throws -> [ChildDTO] {

        let response: [ChildDTO] = try await client
            .from("children")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value

        return response
    }
    
    func addChild(
        userId: UUID,
        name: String,
        dob: Date,
        gender: String?,
        bloodGroup: String?,
        weight: Double?,
        height: Double?,
        photoFilename: String?
    ) async throws -> ChildDTO {

        let child = ChildDTO(
            id: nil,
            user_id: userId,
            name: name,
            dob: dob,
            gender: gender,
            blood_group: bloodGroup,
            weight: weight,
            height: height,
            photo_filename: photoFilename
        )

        let inserted: [ChildDTO] = try await client
            .from("children")
            .insert(child)
            .select()
            .execute()
            .value

        guard let created = inserted.first else {
            throw NSError(domain: "child.insert", code: 0)
        }

        return created
    }

    
    func deleteChild(childId: UUID) async throws {
        try await client
            .from("children")
            .delete()
            .eq("id", value: childId)
            .execute()
    }


    func updateChild(_ child: ChildProfile) async throws {

        struct UpdateRow: Encodable {
            let name: String
            let dob: Date
            let gender: String
            let blood_group: String
            let weight: Double?
            let height: Double?
            let photo_filename: String?
        }


        let row = UpdateRow(
            name: child.name,
            dob: child.dob,   // 🔥 THIS WAS MISSING
            gender: child.gender,
            blood_group: child.bloodGroup,
            weight: child.weight,
            height: child.height,
            photo_filename: child.photoFilename
        )



        try await client
            .from("children")
            .update(row)
            .eq("id", value: child.id)
            .execute()
    }

}

