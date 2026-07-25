//
//  LanguageManager.swift
//  AppSeed
//
//  Created by Claude on 13.03.2026.
//

import Foundation

extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}

final class LanguageManager {

    // MARK: - Shared
    static let shared = LanguageManager()

    // MARK: - Properties
    private(set) var bundle: Bundle

    var currentLanguage: AppLanguage {
        AppLanguage(rawValue: LanguageHelper.selectedLanguage) ?? .english
    }

    var appLocale: Locale {
        Locale(identifier: currentLanguage.rawValue)
    }

    // MARK: - Init
    private init() {
        let code = LanguageHelper.selectedLanguage
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = .main
        }
        AppGroupStorage.selectedLanguage = code
    }

    // MARK: - Change
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }

        LanguageHelper.selectedLanguage = language.rawValue
        LanguageHelper.setAppLanguage()
        AppGroupStorage.selectedLanguage = language.rawValue

        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let newBundle = Bundle(path: path) {
            bundle = newBundle
        }

        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }
}
