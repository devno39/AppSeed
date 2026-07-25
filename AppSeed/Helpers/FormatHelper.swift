//
//  FormatHelper.swift
//  AppSeed
//
//  Created by Claude on 18.07.2026.
//

import Foundation

// Locale-aware numeric formatting — one cached formatter per language.
// Read from background sync handlers too; cache access is lock-guarded and
// formatters are immutable after creation (NumberFormatter reads are thread-safe).
enum FormatHelper {

    private static let lock = NSLock()
    private static var decimalCache: (lang: String, formatter: NumberFormatter)?

    static func decimalString(_ value: Double) -> String {
        lock.lock()
        let lang = LanguageManager.shared.currentLanguage.rawValue
        let formatter: NumberFormatter
        if let cached = decimalCache, cached.lang == lang {
            formatter = cached.formatter
        } else {
            formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            formatter.locale = LanguageManager.shared.appLocale
            decimalCache = (lang, formatter)
        }
        lock.unlock()
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }

    static func decimalString(_ value: Int) -> String {
        decimalString(Double(value))
    }

    static func distance(km: Double) -> String {
        "\(decimalString(km)) km"
    }
}
