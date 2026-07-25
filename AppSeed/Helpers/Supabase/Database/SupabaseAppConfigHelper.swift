//
//  SupabaseAppConfigHelper.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import Foundation
import Supabase

final class SupabaseAppConfigHelper {

    // MARK: - Shared
    static let shared = SupabaseAppConfigHelper()

    // MARK: - Properties
    private var cache: [String: String] = [:]

    // MARK: - Init
    private init() {}

    // MARK: - Keys
    enum ConfigKey: String {
        case minimumSupportedVersion = "minimum_supported_version"
        case termsContent = "terms_content"
        case privacyContent = "privacy_content"
    }

    // MARK: - Fetch
    func fetchAll(completion: BoolClosure? = nil) {
        Task {
            do {
                let configs: [[String: String]] = try await SupabaseManager.shared.client
                    .from("app_config")
                    .select()
                    .execute()
                    .value

                // getValue reads on main — cache writes must land there too.
                await MainActor.run {
                    for config in configs {
                        if let key = config["key"], let value = config["value"] {
                            self.cache[key] = value
                        }
                    }
                    completion?(true)
                }
            } catch {
                log(.error, .supabase, "AppConfig fetch failed: \(error.localizedDescription)")
                await MainActor.run { completion?(false) }
            }
        }
    }

    // MARK: - Get
    func getValue<T>(for key: ConfigKey, as type: T.Type = T.self) -> T? {
        guard let stringValue = cache[key.rawValue] else { return nil }

        if type == String.self { return stringValue as? T }
        if type == Bool.self { return (stringValue == "true") as? T }
        if type == Int.self { return Int(stringValue) as? T }
        if type == Double.self { return Double(stringValue) as? T }

        return nil
    }
}
