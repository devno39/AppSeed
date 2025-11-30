//
//  FalaiStatus.swift
//  AppSeed
//
//  Created by tunay alver on 30.11.2025.
//

enum FalaiStatus: String, Codable {
    case completed  = "COMPLETED"
    case inQueue    = "IN_QUEUE"
    case inProgress = "IN_PROGRESS"
    case failed     = "FAILED"
    case unknown    = "UNKNOWN"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        self = FalaiStatus(rawValue: raw) ?? .unknown
    }
}
