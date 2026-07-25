//
//  SupabaseDatabaseErrorMapper.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import Foundation

struct SupabaseDatabaseErrorMapper {
    struct UserMessage {
        let title: String
        let message: String
    }

    static func userMessage(for error: Error) -> UserMessage? {
        let nsError = error as NSError

        switch nsError.code {
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorTimedOut,
             NSURLErrorNetworkConnectionLost:
            return UserMessage(
                title: Localizable.db_error_title,
                message: Localizable.db_error_network
            )
        default:
            let description = error.localizedDescription.lowercased()
            if description.contains("unauthorized") || description.contains("forbidden") {
                return UserMessage(
                    title: Localizable.db_error_title,
                    message: Localizable.db_error_permission
                )
            }
            return nil
        }
    }
}
