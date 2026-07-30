//
//  QRScannerLocalizable.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import Foundation

enum QRScannerLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "QRScannerLocalizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    static var title: String { localized("title") }
    static var camera_permission_title: String { localized("camera_permission_title") }
    static var camera_permission_message: String { localized("camera_permission_message") }
    static var camera_permission_open_settings: String { localized("camera_permission_open_settings") }
}
