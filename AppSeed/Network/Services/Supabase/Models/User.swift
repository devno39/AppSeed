//
//  User.swift
//  AppSeed
//
//  Created by Codex on 14.02.2026.
//

import Foundation

struct User: Codable {
    let userId: String?
    let displayName: String?
    let email: String?
    let avatarURL: String?
    let birthDate: Date?
    let createdAt: Date?
    let lastLoginAt: Date?
    var lastSeenAt: Date?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case displayName = "display_name"
        case email
        case avatarURL = "avatar_url"
        case birthDate = "birth_date"
        case createdAt = "created_at"
        case lastLoginAt = "last_login_at"
        case lastSeenAt = "last_seen_at"
    }

    init(
        userId: String? = nil,
        displayName: String? = nil,
        email: String? = nil,
        avatarURL: String? = nil,
        birthDate: Date? = nil,
        createdAt: Date? = nil,
        lastLoginAt: Date? = nil,
        lastSeenAt: Date? = nil
    ) {
        self.userId = userId
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.birthDate = birthDate
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.lastSeenAt = lastSeenAt
    }
}
