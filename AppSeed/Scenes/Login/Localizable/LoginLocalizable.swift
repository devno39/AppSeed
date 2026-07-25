//
//  LoginLocalizable.swift
//  AppSeed
//
//  Created by Claude on 19.01.2025.
//

import Foundation

enum LoginLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "LoginLocalizable", bundle: .main, value: "", comment: "")
    }

    static var title: String { localized("title") }
    static var subtitle: String { localized("subtitle") }

    // MARK: - Agreement
    static var agreement: String { localized("agreement") }
    static var agreement_terms: String { localized("agreement_terms") }
    static var agreement_privacy: String { localized("agreement_privacy") }

    // MARK: - Apple Sign In Errors
    static var apple_signin_error_cancelled: String { localized("apple_signin_error_cancelled") }
    static var apple_signin_error_network: String { localized("apple_signin_error_network") }
    static var apple_signin_error_invalid_credential: String { localized("apple_signin_error_invalid_credential") }
    static var apple_signin_error_configuration: String { localized("apple_signin_error_configuration") }
    static var apple_signin_error_device_not_supported: String { localized("apple_signin_error_device_not_supported") }
    static var apple_signin_error_account_disabled: String { localized("apple_signin_error_account_disabled") }
    static var apple_signin_error_unknown: String { localized("apple_signin_error_unknown") }
    static var apple_signin_error_title: String { localized("apple_signin_error_title") }
}
