//
//  ThemeManager.swift
//  AppSeed
//
//  Created by Claude on 13.03.2026.
//

import UIKit

// MARK: - AppTheme
enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light:  .light
        case .dark:   .dark
        }
    }
}

// MARK: - Notification
extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

// MARK: - ThemeManager
final class ThemeManager {
    static let shared = ThemeManager()

    var currentTheme: AppTheme {
        AppTheme(rawValue: UserDefaultsWrapper.selected_theme) ?? .system
    }

    private init() {}

    // App-Group mirroring + widget reload land in Phase 5.
    func setTheme(_ theme: AppTheme) {
        guard theme != currentTheme else { return }
        UserDefaultsWrapper.selected_theme = theme.rawValue
        applyTheme()
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }

    func applyTheme() {
        let style = currentTheme.userInterfaceStyle
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
}
