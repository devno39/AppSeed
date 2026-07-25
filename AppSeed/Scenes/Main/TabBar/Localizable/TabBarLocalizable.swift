//
//  TabBarLocalizable.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import Foundation

enum TabBarLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "TabBarLocalizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    static var home: String { localized("home") }
    static var profile: String { localized("profile") }
}
