//
//  ResponseDalle.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

struct ResponseDalle: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let data: [DalleData]?

    var imageUrl: String? {
        guard let imageUrl = data?.first?.url else { return nil }
        return imageUrl
    }
}

struct DalleData: Codable {
    let url: String?
}

struct ImageResponse: Codable {
    let image_url: String?
}
