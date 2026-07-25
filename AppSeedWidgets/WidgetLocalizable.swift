//
//  WidgetLocalizable.swift
//  AppSeedWidgets
//
//  Created by Claude on 26.07.2026.
//

import Foundation

// Widgets can't use the app's LanguageManager (it depends on app-only state), so
// they resolve their own lproj bundle from the language mirrored into the App Group.
// Strings live in AppSeedWidgets/<lang>.lproj/WidgetLocalizable.strings.
enum WidgetLocalizable {

    private static var bundle: Bundle {
        let langCode = AppGroupStorage.selectedLanguage ?? "en"
        if let path = Bundle.main.path(forResource: langCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "WidgetLocalizable", bundle: bundle, value: "", comment: "")
    }

    // MARK: - Demo
    static var demoTitle: String { localized("demoTitle") }
    static var demoEmpty: String { localized("demoEmpty") }

    // MARK: - Premium
    static var pro: String { localized("pro") }
    static var tapToUnlock: String { localized("tapToUnlock") }
}
