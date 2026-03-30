//
//  ArticleDTO.swift
//  TinyVitals
//
//  Created for dynamically fetched articles.

import Foundation

struct ArticleDTO: Codable {
    let id: UUID?
    let title: String
    let subtitle: String
    let url: String
    let mediaType: String
    let mediaUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case url
        case mediaType = "media_type"
        case mediaUrl = "media_url"
    }
}
