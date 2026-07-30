//
//  HomeLocalizable.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import Foundation

enum HomeLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "HomeLocalizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    static var title: String { localized("title") }
    static var subtitle: String { localized("subtitle") }
    static var shared_item_title: String { localized("shared_item_title") }
}
