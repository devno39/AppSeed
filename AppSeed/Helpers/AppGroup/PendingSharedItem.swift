//
//  PendingSharedItem.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import Foundation

// The suite name is duplicated from AppGroupStorage — the extension can't see app-target code.
struct PendingSharedItem: Codable {
    let url: String?
    let text: String?
    let sharedAt: Date

    private static let suiteName = "group.com.devno39.appseed"
    private static let key = "pending_shared_item"

    init(url: String?, text: String?, sharedAt: Date = Date()) {
        self.url = url
        self.text = text
        self.sharedAt = sharedAt
    }

    static var exists: Bool {
        UserDefaults(suiteName: suiteName)?.data(forKey: key) != nil
    }

    static func save(_ item: PendingSharedItem) {
        guard let data = try? JSONEncoder().encode(item) else { return }
        UserDefaults(suiteName: suiteName)?.set(data, forKey: key)
    }

    static func consume() -> PendingSharedItem? {
        let defaults = UserDefaults(suiteName: suiteName)
        guard let data = defaults?.data(forKey: key),
              let item = try? JSONDecoder().decode(PendingSharedItem.self, from: data) else { return nil }
        defaults?.removeObject(forKey: key)
        return item
    }
}

extension Notification.Name {
    static let sharedItemReceived = Notification.Name("sharedItemReceived")
}
