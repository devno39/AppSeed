//
//  UserSessionManager.swift
//  AppSeed
//
//  Created by Claude on 17.03.2026.
//

import Foundation
import Supabase

// MARK: - Notifications
extension Notification.Name {
    static let userDidChange = Notification.Name("userDidChange")
}

// MARK: - UserSessionManager
final class UserSessionManager {
    static let shared = UserSessionManager()

    // Cached on first use — ISO8601DateFormatter init is one of the more
    // expensive Foundation allocations. Thread-safe for read-only string(from:).
    private static let iso8601Formatter = ISO8601DateFormatter()

    // MARK: - Properties
    private(set) var currentUser: User?
    private var userListener: ListenerHandle?
    private var isFirstSnapshot = true
    // Stale-callback guard: ListenerHandle.remove() unsubscribes async, so an in-flight fetch can
    // complete AFTER stopListening and resurrect the old session. Callbacks compare their captured
    // generation and bail if start/stop advanced it.
    private var sessionGeneration = 0
    private let userService: UserServiceProtocol

    // MARK: - Init
    private init() {
        self.userService = SupabaseUserService()
    }

    // MARK: - Start / Stop
    func startListening() {
        guard let userId = userService.currentUserId else { return }
        if userListener != nil {
            stopListening(wipeCache: false)
        }

        isFirstSnapshot = true
        sessionGeneration += 1
        let generation = sessionGeneration

        userListener = userService.listenUser(id: userId) { [weak self] user in
            guard let self, generation == self.sessionGeneration else { return }
            self.currentUser = user

            if self.isFirstSnapshot {
                self.isFirstSnapshot = false
                self.updateLastSeen()
            }

            NotificationCenter.default.post(name: .userDidChange, object: nil)
        }
    }

    // wipeCache=true on identity change (sign-out/delete); false on internal re-entry.
    func stopListening(wipeCache: Bool) {
        sessionGeneration += 1
        if wipeCache {
            // A different Apple ID must re-enter setup and permissions.
            UserDefaultsWrapper.has_completed_setup = false
            UserDefaultsWrapper.has_shown_permission_sheet = false
        }
        userListener?.remove()
        userListener = nil
        currentUser = nil
        isFirstSnapshot = true
    }

    // MARK: - Refresh
    func refreshUser() {
        guard let userId = currentUser?.userId else { return }
        let generation = sessionGeneration
        userService.getUser(id: userId) { [weak self] user in
            guard let self, let user, generation == self.sessionGeneration else { return }
            self.currentUser = user
            NotificationCenter.default.post(name: .userDidChange, object: nil)
        }
    }

    func reconcileAfterReconnect() {
        // Offline cold launch leaves the session empty (initial fetch skipped on failure) —
        // redo the full start so the first-snapshot side effects run, not just a refresh.
        if currentUser == nil, userService.currentUserId != nil {
            startListening()
            return
        }
        refreshUser()
    }

    // MARK: - Last Seen
    func updateLastSeen() {
        guard let userId = currentUser?.userId else { return }
        let now = Date()
        currentUser?.lastSeenAt = now
        NotificationCenter.default.post(name: .userDidChange, object: nil)

        let fields: [String: AnyJSON] = [
            "last_seen_at": .string(Self.iso8601Formatter.string(from: now))
        ]
        SupabaseDatabaseHelper.update(.users, id: userId, idColumn: "user_id", fields: fields)
    }
}
