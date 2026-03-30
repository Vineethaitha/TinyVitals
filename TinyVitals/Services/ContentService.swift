//
//  ContentService.swift
//  TinyVitals
//
//  Created by Antigravity
//

import Foundation
import Supabase

struct AppContentDTO: Decodable {
    let id: UUID
    let type: String
    let title: String
    let body: String
    let headings: [String]
}

final class ContentService {
    static let shared = ContentService()
    private init() {}
    
    // We reuse the existing Supabase client initialized in SupabaseAuthService
    private var client: SupabaseClient {
        return SupabaseAuthService.shared.client
    }

    /// Fetches the dynamic content from the database based on its unique type ('about', 'terms', 'privacy', 'help').
    func fetchContent(for type: String) async throws -> AppContentDTO {
        return try await client
            .from("app_content")
            .select()
            .eq("type", value: type)
            .single()
            .execute()
            .value
    }
}
