//
//  SplashLocalizable.swift
//  AppSeed
//
//  Created by tunay alver on 24.11.2024.
//

import Foundation

enum SplashLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "SplashLocalizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    static var splash_title: String { localized("splash_title") }
    static var update_title: String { localized("update_title") }
    static var update_message: String { localized("update_message") }
    static var update_button: String { localized("update_button") }
}
