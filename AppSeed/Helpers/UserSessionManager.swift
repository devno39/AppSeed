//
//  UserSessionManager.swift
//  AppSeed
//
//  Created by Claude on 17.03.2026.
//

import Foundation
import AuthenticationServices
import Supabase

// MARK: - Notifications
extension Notification.Name {
    static let userDidChange = Notification.Name("userDidChange")
    static let sessionRevoked = Notification.Name("sessionRevoked")
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCredentialRevoked),
            name: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil
        )
    }

    // MARK: - Start / Stop
    func startListening() {
        guard let userId = userService.currentUserId else { return }
        if userListener != nil {
            stopListening(wipeCache: false)
        }

        // Scope guard for widget snapshots — writes/reads validate against this.
        AppGroupStorage.currentScopeId = userId

        isFirstSnapshot = true
        sessionGeneration += 1
        let generation = sessionGeneration

        userListener = userService.listenUser(id: userId) { [weak self] user in
            guard let self, generation == self.sessionGeneration else { return }
            self.currentUser = user

            if self.isFirstSnapshot {
                self.isFirstSnapshot = false
                self.updateLastSeen()
                // APNs register runs post-auth so the device_tokens upsert has a valid auth.uid().
                PushNotificationManager.shared.requestAuthorizationAndRegister()
            }

            NotificationCenter.default.post(name: .userDidChange, object: nil)
        }
    }

    // wipeCache=true on identity change (sign-out/delete); false on internal re-entry.
    func stopListening(wipeCache: Bool) {
        sessionGeneration += 1
        if wipeCache {
            // Device tokens are already gone — signOut() drops them while auth.uid() still
            // resolves. A different Apple ID must re-enter setup and permissions.
            UserDefaultsWrapper.has_completed_setup = false
            UserDefaultsWrapper.has_shown_permission_sheet = false
            // Purge widget snapshots + drop the scope so ex-user content can't render.
            AppGroupStorage.currentScopeId = nil
            AppGroupStorage.wipe()
        }
        userListener?.remove()
        userListener = nil
        currentUser = nil
        isFirstSnapshot = true
    }

    // MARK: - Sign Out
    // Push tokens must go while auth.uid() still resolves, and the server call has to
    // succeed before anything local is wiped — a half-wiped signed-in state is worse.
    func signOut() async throws {
        if let userId = currentUser?.userId {
            PushNotificationManager.shared.handleSignOut(userId: userId)
        }
        try await userService.signOut()
        stopListening(wipeCache: true)
        ReviewPromptManager.clearMilestoneTracking()
    }

    // MARK: - Apple Credential
    // Apple can revoke from iOS Settings while the app is closed; the Supabase session
    // stays valid on its own, so nothing else would notice.
    func verifyAppleCredential() {
        guard let appleUserId = KeychainHelper.shared.read(key: .appleUserId),
              userService.currentUserId != nil else { return }

        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: appleUserId) { [weak self] state, _ in
            guard state == .revoked || state == .notFound else { return }
            DispatchQueue.main.async { self?.terminateRevokedSession() }
        }
    }

    @objc private func handleCredentialRevoked() {
        terminateRevokedSession()
    }

    private func terminateRevokedSession() {
        guard userService.currentUserId != nil else { return }
        log(.warning, .supabase, "Apple credential revoked — terminating session")
        KeychainHelper.shared.delete(key: .appleUserId)

        Task { @MainActor [weak self] in
            try? await self?.signOut()
            NotificationCenter.default.post(name: .sessionRevoked, object: nil)
        }
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
