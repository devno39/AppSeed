//
//  ResponseFalai.swift
//  AppSeed
//
//  Created by tunay alver on 30.11.2025.
//

struct ResponseFalai: Codable {
    let images: [Image]?
    let timings: Timings?
    let seed: Int?
    let has_nsfw_concepts: [Bool]?
    let prompt: String?
    var imageUrl: String? {
        images?.first?.url
    }

    struct Image: Codable {
        let url: String?
        let width: Int?
        let height: Int?
        let content_type: String?
    }

    struct Timings: Codable {
        let inference: Double?
    }
}
