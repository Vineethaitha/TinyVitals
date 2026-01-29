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
        gender: String?
    ) async throws {

        let child = ChildDTO(
            id: nil,
            user_id: userId,
            name: name,
            dob: dob,
            gender: gender
        )

        try await client
            .from("children")
            .insert(child)
            .execute()
    }
    
    func deleteChild(childId: UUID) async throws {
        try await client
            .from("children")
            .delete()
            .eq("id", value: childId)
            .execute()
    }


}

