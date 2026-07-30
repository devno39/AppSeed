//
//  ItemsLocalizable.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import Foundation

enum ItemsLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ItemsLocalizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    // MARK: - Screen
    static var title: String { localized("title") }

    // MARK: - Empty
    static var empty_title: String { localized("empty_title") }
    static var empty_subtitle: String { localized("empty_subtitle") }
    static var empty_button: String { localized("empty_button") }

    // MARK: - Add Sheet
    static var add_title: String { localized("add_title") }
    static var add_save: String { localized("add_save") }
    static var add_name: String { localized("add_name") }
    static var add_name_placeholder: String { localized("add_name_placeholder") }
    static var add_emoji: String { localized("add_emoji") }
    static var add_note: String { localized("add_note") }
    static var add_note_placeholder: String { localized("add_note_placeholder") }

    // MARK: - Actions
    static var delete: String { localized("delete") }
}
