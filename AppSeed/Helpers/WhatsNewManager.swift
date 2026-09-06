//
//  WhatsNewManager.swift
//  AppSeed
//
//  Created by Claude on 16.08.2026.
//

import UIKit

struct WhatsNewItem {
    let emoji: String
    let text: String
}

enum WhatsNewManager {

    // MARK: - Content
    // Rewritten every release, alongside the version bump — the sheet is what the release notes
    // say, in the app's own voice.
    static var items: [WhatsNewItem] {
        [
            WhatsNewItem(emoji: "✨", text: Localizable.whats_new_1),
            WhatsNewItem(emoji: "⚡️", text: Localizable.whats_new_2),
            WhatsNewItem(emoji: "🐞", text: Localizable.whats_new_3)
        ]
    }

    // MARK: - Gate
    static func shouldShow() -> Bool {
        UserDefaultsWrapper.whats_new_seen_version != UIApplication.appVersion
    }

    static func markShown() {
        UserDefaultsWrapper.whats_new_seen_version = UIApplication.appVersion
    }

    // A first install has nothing new to announce — stamp the current version so the sheet waits
    // for a real update instead of greeting a user who has seen nothing yet.
    static func markCurrentVersionSeenIfNeeded() {
        guard UserDefaultsWrapper.whats_new_seen_version.isEmpty else { return }
        markShown()
    }
}
