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
                if let user = SupabaseRealtimeDecoder.decode(User.self, from: action) {
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
