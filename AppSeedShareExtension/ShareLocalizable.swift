//
//  ShareLocalizable.swift
//  AppSeedShareExtension
//
//  Created by Claude on 28.07.2026.
//

import Foundation

enum ShareLocalizable {

    // The extension can't reach LanguageManager — it loads the lproj the app picked.
    private static var bundle: Bundle {
        let langCode = UserDefaults(suiteName: "group.com.devno39.appseed")?
            .string(forKey: "selectedLanguage") ?? "en"
        if let path = Bundle.main.path(forResource: langCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ShareLocalizable", bundle: bundle, value: "", comment: "")
    }

    static var savedTitle: String { localized("savedTitle") }
    static var savedSubtitle: String { localized("savedSubtitle") }
    static var notFoundTitle: String { localized("notFoundTitle") }
}
