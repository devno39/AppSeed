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

// MARK: - Shared (AppGroup) Wrapper
// Values stored in the AppGroup suite so the widget extension can read them.
@propertyWrapper
struct SharedUserDefault<T> {
    let key: UserDefaultsKeys
    let defaultValue: T

    init(_ key: UserDefaultsKeys, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get { AppGroupStorage.sharedDefaults?.object(forKey: key.rawValue) as? T ?? defaultValue }
        set { AppGroupStorage.sharedDefaults?.set(newValue, forKey: key.rawValue) }
    }
}

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
    // theme
    case selected_theme
    // palette
    case selected_palette
    case custom_palette_hex
    // review prompt
    case review_session_count
    case review_milestone_session_index
    case review_shown_count
    // permission prompt
    case permission_sheet_shown_count
    case permission_sheet_last_session
    // what's new
    case whats_new_seen_version
    // paywall prompt
    case onboarding_paywall_shown
    case paywall_shown_count
    case paywall_last_shown_session
}

// MARK: - UserDefaultsWrapper
struct UserDefaultsWrapper {
    @UserDefault(.tutorials_seen, defaultValue: false)
    static var tutorials_seen: Bool

    @UserDefault(.has_completed_setup, defaultValue: false)
    static var has_completed_setup: Bool

    @SharedUserDefault(.selected_theme, defaultValue: "system")
    static var selected_theme: String

    @SharedUserDefault(.selected_palette, defaultValue: PalettePreset.sunset.rawValue)
    static var selected_palette: String

    @SharedUserDefault(.custom_palette_hex, defaultValue: 0xF5987C)
    static var custom_palette_hex: Int

    @UserDefault(.review_session_count, defaultValue: 0)
    static var review_session_count: Int

    @UserDefault(.review_milestone_session_index, defaultValue: 0)
    static var review_milestone_session_index: Int

    @UserDefault(.review_shown_count, defaultValue: 0)
    static var review_shown_count: Int

    @UserDefault(.permission_sheet_shown_count, defaultValue: 0)
    static var permission_sheet_shown_count: Int

    @UserDefault(.permission_sheet_last_session, defaultValue: 0)
    static var permission_sheet_last_session: Int

    @UserDefault(.whats_new_seen_version, defaultValue: "")
    static var whats_new_seen_version: String

    @UserDefault(.onboarding_paywall_shown, defaultValue: false)
    static var onboarding_paywall_shown: Bool

    @UserDefault(.paywall_shown_count, defaultValue: 0)
    static var paywall_shown_count: Int

    @UserDefault(.paywall_last_shown_session, defaultValue: 0)
    static var paywall_last_shown_session: Int
}
