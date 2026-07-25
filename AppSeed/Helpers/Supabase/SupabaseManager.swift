//
//  SupabaseManager.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import Foundation
import Supabase

final class SupabaseManager {

    // MARK: - Shared
    static let shared = SupabaseManager()

    // MARK: - Client
    let client: SupabaseClient

    // MARK: - Init
    private init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { @Sendable in try Self.decodeTimestamptz($0) }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        client = SupabaseClient(
            supabaseURL: URL(string: Configuration.supabaseURL)!,
            supabaseKey: Configuration.supabaseAnonKey,
            options: SupabaseClientOptions(
                db: .init(encoder: encoder, decoder: decoder),
                auth: .init(emitLocalSessionAsInitialSession: true)
            )
        )
    }

    // MARK: - Date Parser
    // Postgres TIMESTAMPTZ varies (micro/milli/no fraction, tz +00/+00:00/Z); JSONDecoder.iso8601 only handles millisecond.
    private static let isoFormatters: [ISO8601DateFormatter] = {
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return [withFractional, plain]
    }()

    private static let fallbackFormats: [String] = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX",
        "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX",
        "yyyy-MM-dd'T'HH:mm:ss.SSSSXXXXX",
        "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
        "yyyy-MM-dd'T'HH:mm:ssXXXXX",
        "yyyy-MM-dd'T'HH:mm:ssZ"
    ]

    private static func decodeTimestamptz(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        for formatter in isoFormatters {
            if let date = formatter.date(from: string) { return date }
        }

        let fallback = DateFormatter()
        fallback.locale = Locale(identifier: "en_US_POSIX")
        fallback.timeZone = TimeZone(secondsFromGMT: 0)
        for format in fallbackFormats {
            fallback.dateFormat = format
            if let date = fallback.date(from: string) { return date }
        }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot decode date from \(string)"
        )
    }
}
