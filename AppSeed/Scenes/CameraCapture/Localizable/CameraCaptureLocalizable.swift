//
//  CameraCaptureLocalizable.swift
//  AppSeed
//
//  Created by Claude on 14.08.2026.
//

import Foundation

enum CameraCaptureLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "CameraCaptureLocalizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    static var permission_title: String { localized("permission_title") }
    static var permission_message: String { localized("permission_message") }
    static var permission_settings: String { localized("permission_settings") }
    static var unavailable_title: String { localized("unavailable_title") }
    static var unavailable_message: String { localized("unavailable_message") }
    static var preview_use: String { localized("preview_use") }
}
