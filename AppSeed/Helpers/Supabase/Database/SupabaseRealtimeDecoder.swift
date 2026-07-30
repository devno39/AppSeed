//
//  SupabaseRealtimeDecoder.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import Foundation
import Supabase

enum SupabaseRealtimeDecoder {

    // MARK: - Decoder
    private static let decoder: JSONDecoder = {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        let dateOnly = DateFormatter()
        dateOnly.dateFormat = "yyyy-MM-dd"
        dateOnly.timeZone = TimeZone(identifier: "UTC")
        dateOnly.locale = Locale(identifier: "en_US_POSIX")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let raw = try decoder.singleValueContainer().decode(String.self)
            // Postgres sends microsecond fractions; ISO8601DateFormatter reads at most 3 digits.
            let trimmed = raw.replacingOccurrences(of: #"(\.\d{3})\d+"#, with: "$1", options: .regularExpression)
            if let date = fractional.date(from: trimmed) ?? plain.date(from: trimmed) ?? dateOnly.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unrecognized date: \(raw)")
            )
        }
        return decoder
    }()

    // MARK: - Decode
    // The change event carries the full row, so decoding it saves a REST round trip per
    // event. Returns nil for deletes (the event ships the key only) and for any decode
    // failure — both mean "go ask REST".
    static func decode<T: Decodable>(_ type: T.Type, from action: AnyAction) -> T? {
        let record: [String: AnyJSON]?
        switch action {
        case .insert(let insert): record = insert.record
        case .update(let update): record = update.record
        case .delete:             record = nil
        }
        guard let record else { return nil }

        do {
            let data = try JSONEncoder().encode(record)
            return try decoder.decode(T.self, from: data)
        } catch {
            log(.warning, .supabase, "Realtime decode fell back to REST: \(error)")
            return nil
        }
    }
}
