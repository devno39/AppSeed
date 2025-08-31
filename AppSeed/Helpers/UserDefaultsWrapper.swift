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
    // gpt_model
    case gpt_model_free
    case gpt_model_premium
}
