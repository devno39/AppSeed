//
//  ResponseError.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

public struct ResponseError: Codable {
    let message: String?
    let type: String?
    let param: String?
    let code: String?
}
