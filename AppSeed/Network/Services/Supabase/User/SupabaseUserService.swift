//
//  SupabaseUserService.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import Foundation
import Supabase

final class SupabaseUserService: UserServiceProtocol {

    // MARK: - Client
    private var client: SupabaseClient { SupabaseManager.shared.client }

    // MARK: - Auth
    var currentUserId: String? {
        client.auth.currentUser?.id.uuidString.lowercased()
    }

    var isLoggedIn: Bool {
        client.auth.currentUser != nil
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    // MARK: - Read
    func getUser(id: String, completion: @escaping AnyClosure<User?>) {
        SupabaseDatabaseHelper.get(.users, id: id, idColumn: "user_id", as: User.self, completion: completion)
    }

    func listenUser(id: String, completion: @escaping AnyClosure<User?>) -> ListenerHandle {
        let channel = client.realtimeV2.channel("user-\(UUID().uuidString.prefix(8))")

        let onChange = channel.postgresChange(
            AnyAction.self,
            table: "users",
            filter: .eq("user_id", value: id)
        )

        Task { [weak self] in
            do {
                try await channel.subscribeWithError()
                log(.success, .supabase, "Realtime subscribed: users")
            } catch {
                log(.error, .supabase, "Realtime subscribe failed: users - \(error.localizedDescription)")
            }

            self?.getUserSkippingFailure(id: id, completion: completion)

            for await action in onChange {
                if let user = Self.decodeUser(from: action) {
                    await MainActor.run { completion(user) }
                } else {
                    self?.getUserSkippingFailure(id: id, completion: completion)
                }
            }
        }

        return ListenerHandle {
            Task { await channel.unsubscribe() }
        }
    }

    // Listener path only: a transient fetch error must not surface as "user row gone" —
    // UserSessionManager would run the false-wipe branch (e.g. airplane-mode cold launch).
    private func getUserSkippingFailure(id: String, completion: @escaping AnyClosure<User?>) {
        SupabaseDatabaseHelper.getResult(.users, id: id, idColumn: "user_id", as: User.self) { result in
            if case .success(let user) = result { completion(user) }
        }
    }

    // MARK: - Realtime Decode
    // The change event already carries the full row — decoding it saves a REST round trip
    // per event (root of the .userDidChange amplification). Any failure falls back to REST.
    private static let realtimeDecoder: JSONDecoder = {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        let dateOnly = DateFormatter()
        dateOnly.dateFormat = "yyyy-MM-dd"
        dateOnly.timeZone = TimeZone(identifier: "UTC")
        dateOnly.locale = Locale(identifier: "en_US_POSIX")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { d in
            let raw = try d.singleValueContainer().decode(String.self)
            // Postgres sends microsecond fractions; ISO8601DateFormatter reads at most 3 digits.
            let trimmed = raw.replacingOccurrences(of: #"(\.\d{3})\d+"#, with: "$1", options: .regularExpression)
            if let date = fractional.date(from: trimmed) ?? plain.date(from: trimmed) ?? dateOnly.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorrupted(.init(codingPath: d.codingPath, debugDescription: "Unrecognized date: \(raw)"))
        }
        return decoder
    }()

    private static func decodeUser(from action: AnyAction) -> User? {
        let record: [String: AnyJSON]?
        switch action {
        case .insert(let insert): record = insert.record
        case .update(let update): record = update.record
        case .delete: record = nil   // delete ships the key only — REST confirms the absence
        }
        guard let record else { return nil }
        do {
            let data = try JSONEncoder().encode(record)
            return try realtimeDecoder.decode(User.self, from: data)
        } catch {
            log(.warning, .supabase, "Realtime user decode fell back to REST: \(error)")
            return nil
        }
    }

    // MARK: - Write
    func upsertOnLogin(userId: String, data: [String: Any], completion: AnyClosure<Error?>?) {
        var jsonData: [String: AnyJSON] = [:]
        for (key, value) in data {
            if let string = value as? String {
                jsonData[key] = .string(string)
            } else if let date = value as? Date {
                jsonData[key] = .string(ISO8601DateFormatter().string(from: date))
            }
        }
        jsonData["user_id"] = .string(userId)

        SupabaseDatabaseHelper.upsert(.users, data: jsonData, completion: completion)
    }

    func updateProfile(userId: String, fields: [String: Any], completion: AnyClosure<Error?>?) {
        var jsonFields: [String: AnyJSON] = [:]
        for (key, value) in fields {
            if let string = value as? String {
                jsonFields[key] = .string(string)
            } else if let double = value as? Double {
                jsonFields[key] = .double(double)
            } else if let date = value as? Date {
                jsonFields[key] = .string(ISO8601DateFormatter().string(from: date))
            }
        }
        SupabaseDatabaseHelper.update(.users, id: userId, idColumn: "user_id", fields: jsonFields, completion: completion)
    }

    // MARK: - Delete
    // delete_my_account (SECURITY DEFINER) atomically purges the account's rows and deletes the auth user.
    // Storage cleanup (profile image) stays client-side.
    func deleteAccount(userId: String, completion: @escaping AnyClosure<Error?>) {
        Task {
            do {
                try await client.rpc("delete_my_account").execute()
                // Best-effort after the row is gone — deleting first left a live account with a broken avatar on RPC failure.
                SupabaseStorageHelper.deleteImage(path: .profileImages, fileName: userId)
                try await client.auth.signOut()

                await MainActor.run { completion(nil) }
            } catch {
                log(.error, .supabase, "Delete account failed: \(error.localizedDescription)")
                await MainActor.run { completion(error) }
            }
        }
    }
}
