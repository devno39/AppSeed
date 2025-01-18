//
//  ResponseDALLE.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

struct ResponseDALLE: Codable {
    let created: Int?
    let data: [ResponseDALLEData]?

    var imageUrl: String? {
        data?.first?.url
    }
    
    struct ResponseDALLEData: Codable {
        let url: String?
    }
}
