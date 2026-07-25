//
//  PaywallLocalizable.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import Foundation

enum PaywallLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "PaywallLocalizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    // MARK: - Header
    static var title: String { localized("title") }
    static var subtitle: String { localized("subtitle") }

    // MARK: - Features
    static var feature_1_title: String { localized("feature_1_title") }
    static var feature_1_subtitle: String { localized("feature_1_subtitle") }
    static var feature_2_title: String { localized("feature_2_title") }
    static var feature_2_subtitle: String { localized("feature_2_subtitle") }
    static var feature_3_title: String { localized("feature_3_title") }
    static var feature_3_subtitle: String { localized("feature_3_subtitle") }

    // MARK: - Plans
    static var plan_monthly: String { localized("plan_monthly") }
    static var plan_per_month: String { localized("plan_per_month") }
    static var plan_yearly: String { localized("plan_yearly") }
    static var plan_per_year: String { localized("plan_per_year") }
    static var plan_save: String { localized("plan_save") }
    static var plan_popular: String { localized("plan_popular") }

    // MARK: - Actions
    static var cta_continue: String { localized("cta_continue") }
    static var restore: String { localized("restore") }
    static var terms: String { localized("terms") }
    static var privacy: String { localized("privacy") }

    // MARK: - Success
    static var success_title: String { localized("success_title") }
    static var success_subtitle: String { localized("success_subtitle") }
}
