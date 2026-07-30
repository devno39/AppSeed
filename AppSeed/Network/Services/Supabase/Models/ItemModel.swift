//
//  ItemModel.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import Foundation

struct ItemModel: Codable, Equatable {

    // MARK: - Properties
    let id: String
    let userId: String
    var title: String
    var note: String?
    var emoji: String?
    var isDone: Bool
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, note, emoji
        case userId = "user_id"
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - Init
    init(
        id: String = UUID().uuidString.lowercased(),
        userId: String,
        title: String,
        note: String? = nil,
        emoji: String? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.note = note
        self.emoji = emoji
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
