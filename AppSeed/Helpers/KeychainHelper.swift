//
//  KeychainHelper.swift
//  AppSeed
//
//  Created by tunay alver on 12.01.2025.
//

import Foundation
import Security

final class KeychainHelper {
    // MARK: - Singleton
    static let shared = KeychainHelper()
    
    // MARK: - Init
    private init() {}

    // MARK: - Save
    func save(key: KeychainKeys, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            log(.error, .keychain, "save failed for key: \(key.rawValue), status: \(status)")
        } else {
            log(.success, .keychain, "saved: \(key.rawValue)")
        }
    }

    // MARK: - Read
    func read(key: KeychainKeys) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// MARK: - Keys
extension KeychainHelper {
    enum KeychainKeys: String {
        case gptKey
        case replicateKey
        case falaiKey
    }
}
