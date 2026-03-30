//
//  ArticleService.swift
//  TinyVitals
//
//  Created for fetching articles from the database.

import Foundation
import Supabase

final class ArticleService {

    static let shared = ArticleService()
    private init() {}

    private let client = SupabaseAuthService.shared.client

    func fetchArticles() async throws -> [ArticleDTO] {
        try await client
            .from("articles")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
