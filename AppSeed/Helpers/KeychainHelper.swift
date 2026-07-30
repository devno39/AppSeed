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

    // MARK: - Query
    // Class + account only — the shared match key. Accessibility is set on write (save) so delete
    // still matches items stored under the old accessibility (clean upgrade, no duplicate-item error).
    private func baseQuery(for account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
    }

    // MARK: - Save
    func save(key: KeychainKeys, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        SecItemDelete(baseQuery(for: key.rawValue) as CFDictionary)

        var query = baseQuery(for: key.rawValue)
        query[kSecValueData as String] = data
        // AfterFirstUnlock keeps it readable post-first-unlock; ThisDeviceOnly keeps it off iCloud backup.
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            log(.error, .keychain, "save failed for key: \(key.rawValue), status: \(status)")
        } else {
            log(.success, .keychain, "saved: \(key.rawValue)")
        }
    }

    // MARK: - Read
    func read(key: KeychainKeys) -> String? {
        var query = baseQuery(for: key.rawValue)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete
    @discardableResult
    func delete(key: String) -> Bool {
        let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
        return status == errSecSuccess
    }

    @discardableResult
    func delete(key: KeychainKeys) -> Bool {
        delete(key: key.rawValue)
    }
}

// MARK: - Keys
extension KeychainHelper {
    enum KeychainKeys: String {
        case gptKey
        case replicateKey
        case falaiKey
        // Stable per-session nonce stamped into widget snapshots (survives app restarts).
        case widgetSessionNonce
        // Apple's own user identifier — the only key getCredentialState accepts.
        case appleUserId
    }
}
