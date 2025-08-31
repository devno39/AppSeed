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

    var message: String? { content?.message }
    var mainElements: [String]? { content?.mainElements }
    var content: Content? {
        let cleaned = JsonClener.clean(choices?.first?.message?.content)
        return Content.decode(cleaned)
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

struct Content: Codable {
    let message: String?
    let mainElements: [String]?
}

struct UsageGPT: Codable {
    let prompt_tokens: Int?
    let completion_tokens: Int?
    let total_tokens: Int?
}
