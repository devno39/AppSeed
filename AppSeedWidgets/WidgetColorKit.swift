//
//  WidgetColorKit.swift
//  AppSeedWidgets
//
//  Created by Claude on 26.07.2026.
//

import SwiftUI
import UIKit

// MARK: - Theme

enum WidgetAppTheme: String {
    case system, light, dark
}

// MARK: - Palette preset (mirrors PalettePreset — keep in sync)

enum WidgetPalettePreset: String {
    case sunset, ocean, rose, lavender, mint, custom

    var primaryHex: Int {
        switch self {
        case .sunset:   return 0xF5987C
        case .ocean:    return 0x5A9FC6
        case .rose:     return 0xD47A9F
        case .lavender: return 0x9B87C2
        case .mint:     return 0x5FB08E
        case .custom:   return WidgetTheme.customPaletteHex
        }
    }
}

// MARK: - Theme reader

enum WidgetTheme {
    static var current: WidgetAppTheme {
        let raw = AppGroupStorage.sharedDefaults?.string(forKey: "selected_theme") ?? "system"
        return WidgetAppTheme(rawValue: raw) ?? .system
    }

    static var palette: WidgetPalettePreset {
        let raw = AppGroupStorage.sharedDefaults?.string(forKey: "selected_palette") ?? "sunset"
        return WidgetPalettePreset(rawValue: raw) ?? .sunset
    }

    static var customPaletteHex: Int {
        AppGroupStorage.sharedDefaults?.object(forKey: "custom_palette_hex") as? Int ?? 0xF5987C
    }

    static var accentUIColor: UIColor {
        UIColor(rgb: palette.primaryHex)
    }

    static var accentColor: Color {
        Color(uiColor: accentUIColor)
    }
}

// MARK: - Colors (mirrors Colors.xcassets — keep in sync with main app)

enum WidgetColors {
    static var backgroundPrimary: Color { dynamic(light: 0xF8F8F8, dark: 0x1C1D22) }
    static var backgroundSecondary: Color { dynamic(light: 0xFFFFFF, dark: 0x262730) }
    static var backgroundTertiary: Color { dynamic(light: 0xF0F0F0, dark: 0x2E2F38) }
    static var backgroundBorder: Color { dynamic(light: 0xEBEBEB, dark: 0x3A3B45) }
    static var textPrimary: Color { dynamic(light: 0x1A1A1A, dark: 0xF5F5F5) }
    static var textSecondary: Color { dynamic(light: 0x808080, dark: 0xCFCFD4) }

    private static func dynamic(light: Int, dark: Int) -> Color {
        Color(uiColor: UIColor { trait in
            let style: UIUserInterfaceStyle = {
                switch WidgetTheme.current {
                case .light:  return .light
                case .dark:   return .dark
                case .system: return trait.userInterfaceStyle
                }
            }()
            return style == .dark ? UIColor(rgb: dark) : UIColor(rgb: light)
        })
    }
}

// MARK: - Color / UIColor hex helpers

extension UIColor {
    convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }

    convenience init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&int)
        self.init(
            red: CGFloat((int >> 16) & 0xFF) / 255,
            green: CGFloat((int >> 8) & 0xFF) / 255,
            blue: CGFloat(int & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension Color {
    init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&int)
        self.init(
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255
        )
    }

    init(hex: Int) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
