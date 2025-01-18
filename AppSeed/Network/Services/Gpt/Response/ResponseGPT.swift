//
//  ResponseGPT.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

struct ResponseGPT: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [ChoiceGPT]?
    let usage: UsageGPT?
    
    var message: String? {
        guard let content = choices?.first?.message?.content else { return nil }
        return content
    }
}

struct ChoiceGPT: Codable {
    let index: Int?
    let message: MessageGPT?
    let finish_reason: String?
}

struct MessageGPT: Codable {
    let role: String?
    let content: String?
}

struct UsageGPT: Codable {
    let prompt_tokens: Int?
    let completion_tokens: Int?
    let total_tokens: Int?
}
