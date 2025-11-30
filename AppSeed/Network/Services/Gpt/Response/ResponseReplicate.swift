//
//  ResponseReplicate.swift
//  AppSeed
//
//  Created by tunay alver on 31.08.2025.
//

struct ResponseReplicate: Codable {
    let id: String?
    let status: String?
    let output: [String]?

    var imageUrl: String? {
        output?.first
    }
}
