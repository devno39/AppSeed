//
//  SupabaseAppleSignInError.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import Foundation
import AuthenticationServices

enum SupabaseAppleSignInError: LocalizedError {
    case cancelled
    case network
    case invalidCredential
    case appleConfiguration
    case deviceNotSupported
    case accountDisabled
    case unknown

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return LoginLocalizable.apple_signin_error_cancelled
        case .network:
            return LoginLocalizable.apple_signin_error_network
        case .invalidCredential:
            return LoginLocalizable.apple_signin_error_invalid_credential
        case .appleConfiguration:
            return LoginLocalizable.apple_signin_error_configuration
        case .deviceNotSupported:
            return LoginLocalizable.apple_signin_error_device_not_supported
        case .accountDisabled:
            return LoginLocalizable.apple_signin_error_account_disabled
        case .unknown:
            return LoginLocalizable.apple_signin_error_unknown
        }
    }

    static func map(_ error: Error) -> SupabaseAppleSignInError {
        let nsError = error as NSError

        // MARK: - Apple AuthenticationServices Errors
        if nsError.domain == ASAuthorizationError.errorDomain {
            switch ASAuthorizationError.Code(rawValue: nsError.code) {
            case .canceled:
                return .cancelled
            case .failed:
                return .appleConfiguration
            case .notHandled:
                return .appleConfiguration
            case .invalidResponse:
                return .invalidCredential
            case .notInteractive:
                return .deviceNotSupported
            default:
                return .unknown
            }
        }

        // MARK: - Apple AKAuthenticationError
        if nsError.domain == "AKAuthenticationError" {
            return .appleConfiguration
        }

        // MARK: - Network Errors
        if nsError.domain == NSURLErrorDomain {
            return .network
        }

        // MARK: - Supabase Auth Errors
        let description = error.localizedDescription.lowercased()
        if description.contains("invalid") || description.contains("credential") {
            return .invalidCredential
        }
        if description.contains("disabled") {
            return .accountDisabled
        }

        return .unknown
    }
}
