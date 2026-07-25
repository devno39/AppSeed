//
//  ProfileLocalizable.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import Foundation

enum ProfileLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "ProfileLocalizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    // MARK: - Screen
    static var title: String { localized("title") }

    // MARK: - Sections
    static var section_account: String { localized("section_account") }
    static var section_app: String { localized("section_app") }
    static var section_premium: String { localized("section_premium") }
    static var section_support: String { localized("section_support") }
    static var section_session: String { localized("section_session") }

    // MARK: - Items
    static var item_edit_profile: String { localized("item_edit_profile") }
    static var item_language: String { localized("item_language") }
    static var item_theme: String { localized("item_theme") }
    static var item_go_premium: String { localized("item_go_premium") }
    static var item_go_premium_subtitle: String { localized("item_go_premium_subtitle") }
    static var item_feedback: String { localized("item_feedback") }
    static var item_logout: String { localized("item_logout") }
    static var item_delete_account: String { localized("item_delete_account") }

    // MARK: - Edit Profile
    static var edit_title: String { localized("edit_title") }
    static var edit_save: String { localized("edit_save") }
    static var edit_photo: String { localized("edit_photo") }
    static var edit_name: String { localized("edit_name") }
    static var edit_name_placeholder: String { localized("edit_name_placeholder") }
    static var edit_birth_date: String { localized("edit_birth_date") }
    static var edit_birth_date_placeholder: String { localized("edit_birth_date_placeholder") }

    // MARK: - Theme
    static var theme_system: String { localized("theme_system") }
    static var theme_light: String { localized("theme_light") }
    static var theme_dark: String { localized("theme_dark") }

    // MARK: - Alerts
    static var alert_cancel: String { localized("alert_cancel") }

    static var logout_alert_title: String { localized("logout_alert_title") }
    static var logout_alert_message: String { localized("logout_alert_message") }
    static var logout_alert_confirm: String { localized("logout_alert_confirm") }
    static var logout_failed_title: String { localized("logout_failed_title") }
    static var logout_failed_message: String { localized("logout_failed_message") }

    static var delete_account_alert_title: String { localized("delete_account_alert_title") }
    static var delete_account_alert_message: String { localized("delete_account_alert_message") }
    static var delete_account_alert_confirm: String { localized("delete_account_alert_confirm") }
    static var delete_account_failed_title: String { localized("delete_account_failed_title") }
    static var delete_account_failed_message: String { localized("delete_account_failed_message") }
}
