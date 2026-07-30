//
//  SetupLocalizable.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import Foundation

enum SetupLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "SetupLocalizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    static var title: String { localized("title") }
    static var subtitle: String { localized("subtitle") }
    static var name_label: String { localized("name_label") }
    static var name_placeholder: String { localized("name_placeholder") }
    static var birthday_label: String { localized("birthday_label") }
    static var birthday_placeholder: String { localized("birthday_placeholder") }
    static var save: String { localized("save") }

    // MARK: - Permissions
    static var permission_title: String { localized("permission_title") }
    static var permission_subtitle: String { localized("permission_subtitle") }
    static var permission_location_title: String { localized("permission_location_title") }
    static var permission_location_subtitle: String { localized("permission_location_subtitle") }
    static var permission_notification_title: String { localized("permission_notification_title") }
    static var permission_notification_subtitle: String { localized("permission_notification_subtitle") }
    static var permission_photos_title: String { localized("permission_photos_title") }
    static var permission_photos_subtitle: String { localized("permission_photos_subtitle") }
}
