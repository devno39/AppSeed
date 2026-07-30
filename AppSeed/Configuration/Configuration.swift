//
//  Configuration.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

final class Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    // Configuration names are not compilation conditions — `#if Release` is silently
    // false in a release build. Only DEBUG is defined, by the Develop configuration.
    static var isRelease: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }

    static var isDevelop: Bool {
        !isRelease
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

extension Configuration {
    static var isIpad: Bool {
        UIDevice.isIpad
    }

    static var appVersion: String {
        UIApplication.appVersion
    }

    // MARK: - Legal (placeholder URLs — swap per app)
    static var termsURL: String { "https://example.com/terms" }
    static var privacyURL: String { "https://example.com/privacy" }

    // MARK: - Supabase
    static var supabaseURL: String {
        (try? value(for: "SUPABASE_URL")) ?? ""
    }

    static var supabaseAnonKey: String {
        (try? value(for: "SUPABASE_ANON_KEY")) ?? ""
    }
}
