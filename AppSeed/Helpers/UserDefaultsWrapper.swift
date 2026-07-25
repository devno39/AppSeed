//
//  UserDefaultsWrapper.swift
//  AppSeed
//
//  Created by tunay alver on 16.01.2025.
//

import Foundation

// MARK: - Wrapper
@propertyWrapper
struct UserDefault<T> {
    let key: UserDefaultsKeys
    let defaultValue: T

    init(_ key: UserDefaultsKeys, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key.rawValue) }
    }
}

// A @SharedUserDefault wrapper (App-Group suite, widget-readable) lands with the Phase 5 widget kit.

// MARK: - Wrapper Codable
@propertyWrapper
struct UserDefaultCodable<T: Codable> {
    let key: UserDefaultsKeys
    let defaultValue: T

    init(_ key: UserDefaultsKeys, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get { UserDefaults.standard.getObject(forKey: key, type: T.self) ?? defaultValue }
        set { UserDefaults.standard.setObject(newValue, forKey: key) }
    }
}

// MARK: - UserDefaults
extension UserDefaults {
    func setObject<T: Codable>(_ object: T, forKey key: UserDefaultsKeys) {
        guard let encoded = object.encodeToData() else { return }
        set(encoded, forKey: key.rawValue)
    }

    func getObject<T: Codable>(forKey key: UserDefaultsKeys, type: T.Type) -> T? {
        guard let data = data(forKey: key.rawValue) else { return nil }
        let object = T.decode(data)
        return object
    }

    func forceSave() {
        synchronize()
    }
}

// MARK: - Keys
enum UserDefaultsKeys: String {
    // language
    case selectedLanguage
    // tutorials
    case tutorials_seen
    // setup
    case has_completed_setup
    case has_shown_permission_sheet
    // theme
    case selected_theme
    // palette
    case selected_palette
    case custom_palette_hex
    // review prompt
    case review_session_count
    case review_milestone_session_index
    case review_shown_count
}

// MARK: - UserDefaultsWrapper
struct UserDefaultsWrapper {
    @UserDefault(.tutorials_seen, defaultValue: false)
    static var tutorials_seen: Bool

    @UserDefault(.has_completed_setup, defaultValue: false)
    static var has_completed_setup: Bool

    @UserDefault(.has_shown_permission_sheet, defaultValue: false)
    static var has_shown_permission_sheet: Bool

    @UserDefault(.selected_theme, defaultValue: "system")
    static var selected_theme: String

    @UserDefault(.selected_palette, defaultValue: PalettePreset.sunset.rawValue)
    static var selected_palette: String

    @UserDefault(.custom_palette_hex, defaultValue: 0xF5987C)
    static var custom_palette_hex: Int

    @UserDefault(.review_session_count, defaultValue: 0)
    static var review_session_count: Int

    @UserDefault(.review_milestone_session_index, defaultValue: 0)
    static var review_milestone_session_index: Int

    @UserDefault(.review_shown_count, defaultValue: 0)
    static var review_shown_count: Int
}
