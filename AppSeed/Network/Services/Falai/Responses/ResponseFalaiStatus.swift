//
//  ResponseFalaiStatus.swift
//  AppSeed
//
//  Created by tunay alver on 30.11.2025.
//

struct ResponseFalaiStatus: Codable {
    let status: FalaiStatus?
    let request_id: String?
    let response_url: String?
    let status_url: String?
    let cancel_url: String?
    let logs: String?
    let metrics: Metrics?
    
    struct Metrics: Codable {
        let inference_time: Double?
    }
}
