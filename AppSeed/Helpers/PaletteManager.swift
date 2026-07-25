//
//  PaletteManager.swift
//  AppSeed
//
//  Created by Claude on 13.03.2026.
//

import UIKit

// MARK: - PalettePreset
enum PalettePreset: String {
    case sunset
    case ocean
    case rose
    case lavender
    case mint
    case custom

    static let allPresets: [PalettePreset] = [.sunset, .ocean, .rose, .lavender, .mint]

    var colors: (primary: Int, secondary: Int, tertiary: Int) {
        switch self {
        case .sunset:   return (0xF5987C, 0xFFD19D, 0xF9C590)
        case .ocean:    return (0x5A9FC6, 0x8DD0F0, 0x6BB5E0)
        case .rose:     return (0xD47A9F, 0xF0C0D0, 0xE8A0BF)
        case .lavender: return (0x9B87C2, 0xD0C4E8, 0xB8A9D4)
        case .mint:     return (0x5FB08E, 0xA5E0C4, 0x7DC8A8)
        case .custom:   return PaletteManager.shared.customColors
        }
    }

    var title: String {
        rawValue.capitalized
    }
}

// MARK: - PaletteUpdatable
protocol PaletteUpdatable: AnyObject {
    func updatePaletteColors()
}

// MARK: - Notification
extension Notification.Name {
    static let paletteDidChange = Notification.Name("paletteDidChange")
}

// MARK: - PaletteManager
final class PaletteManager {
    static let shared = PaletteManager()

    var currentPreset: PalettePreset {
        PalettePreset(rawValue: UserDefaultsWrapper.selected_palette) ?? .sunset
    }

    var customColors: (primary: Int, secondary: Int, tertiary: Int) {
        let primary = UserDefaultsWrapper.custom_palette_hex
        let color = UIColor(rgb: primary)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let secondary = UIColor(hue: h, saturation: max(s - 0.15, 0.05), brightness: min(b + 0.15, 1.0), alpha: 1.0)
        let tertiary = UIColor(hue: h, saturation: max(s - 0.08, 0.05), brightness: min(b + 0.08, 1.0), alpha: 1.0)
        return (primary, secondary.rgbHex, tertiary.rgbHex)
    }

    private init() {}

    func setPreset(_ preset: PalettePreset) {
        guard preset != currentPreset else { return }
        UserDefaultsWrapper.selected_palette = preset.rawValue
        NotificationCenter.default.post(name: .paletteDidChange, object: nil)
    }

    func setCustomColor(_ color: UIColor) {
        UserDefaultsWrapper.custom_palette_hex = color.rgbHex
        UserDefaultsWrapper.selected_palette = PalettePreset.custom.rawValue
        NotificationCenter.default.post(name: .paletteDidChange, object: nil)
    }

    func resetToDefaultIfNeeded() {
        guard currentPreset != .sunset else { return }
        UserDefaultsWrapper.selected_palette = PalettePreset.sunset.rawValue
        NotificationCenter.default.post(name: .paletteDidChange, object: nil)
    }

    func color(for palette: Palette) -> UIColor {
        let colors = currentPreset.colors
        let hex: Int
        switch palette {
        case .palette1: hex = colors.primary
        case .palette2: hex = colors.secondary
        case .palette3: hex = colors.tertiary
        }
        return UIColor(rgb: hex)
    }
}
