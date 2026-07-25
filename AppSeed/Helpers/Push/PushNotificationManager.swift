//
//  PushNotificationManager.swift
//  AppSeed
//
//  Created by Claude on 26.07.2026.
//

import Foundation
import UIKit
import UserNotifications
import Supabase

// Generic push core: notification authorization, APNs registration, device-token
// persistence, the silent-push widget-refresh path, and the foreground-presentation
// delegate. Domain routing (which banner deep-links where, premium gating, pair
// checks) is deliberately absent — wire that per app.
final class PushNotificationManager: NSObject {
    // MARK: - Singleton
    static let shared = PushNotificationManager()

    // Cached — ISO8601DateFormatter init is an expensive Foundation allocation.
    private static let iso8601Formatter = ISO8601DateFormatter()

    // MARK: - Init
    private override init() { super.init() }

    // MARK: - Register
    // Ask for alert authorization, then register for remote notifications regardless
    // of the answer — silent pushes work without alert permission, and the APNs token
    // is only delivered after registerForRemoteNotifications(). Main thread only.
    func requestAuthorizationAndRegister() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if let error {
                log(.error, .push, "authorization request failed: \(error.localizedDescription)")
            } else {
                log(.info, .push, "notification authorization granted=\(granted)")
            }
            self?.registerForRemoteNotifications()
        }
    }

    private func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            log(.info, .push, "called registerForRemoteNotifications")
        }
    }

    // MARK: - AppDelegate callbacks
    func handleDidRegister(deviceToken: Data) {
        let tokenHex = deviceToken.map { String(format: "%02x", $0) }.joined()

        // Registration runs post-auth (from UserSessionManager), so a user id is
        // available for the RLS-guarded own-row upsert.
        guard let userId = UserSessionManager.shared.currentUser?.userId else {
            log(.warning, .push, "APNs token arrived with no session; upsert skipped")
            return
        }

        let tokenPreview = "\(tokenHex.prefix(8))...\(tokenHex.suffix(4))"
        log(.success, .push, "APNs token: \(tokenPreview)")

        // Upsert conflicts on the token PK — re-registration is idempotent, and a new
        // owner on the same device flips user_id. Fire-and-forget, not tied to any UI.
        let data: [String: AnyJSON] = [
            "token": .string(tokenHex),
            "user_id": .string(userId),
            "platform": .string("ios"),
            "updated_at": .string(Self.iso8601Formatter.string(from: Date()))
        ]
        SupabaseDatabaseHelper.upsert(.deviceTokens, data: data)
    }

    func handleDidFailToRegister(error: Error) {
        log(.error, .push, "registerForRemoteNotifications failed: \(error.localizedDescription)")
    }

    // MARK: - Sign-out
    // Remove this account's device tokens so a signed-out device stops receiving
    // pushes. Runs under the delete-own RLS policy — call it BEFORE auth.signOut()
    // so auth.uid() still resolves. userId is passed in because the caller nils the
    // session immediately after.
    func handleSignOut(userId: String) {
        SupabaseDatabaseHelper.delete(.deviceTokens, id: userId, idColumn: "user_id")
    }

    // MARK: - Silent push
    // Parses the silent payload, guards on app state + cold launch, then refreshes
    // widgets through WidgetSyncService. A 25s safety net guarantees the completion
    // handler fires inside iOS's background budget.
    func handleSilentPush(
        userInfo: [AnyHashable: Any],
        completion: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let aps = userInfo["aps"] as? [AnyHashable: Any],
              (aps["content-available"] as? Int) == 1 else {
            log(.warning, .push, "silent push missing content-available flag")
            completion(.noData)
            return
        }

        // payload_version 1 = silent; visible pushes (2) take the alert/NSE path.
        let version = userInfo["payload_version"] as? Int ?? 0
        guard version == 1 else {
            log(.warning, .push, "silent push unknown protocol version \(version)")
            completion(.noData)
            return
        }

        if UIApplication.shared.applicationState == .active {
            log(.info, .push, "silent push skipped: app foreground (foreground reconcile handles it)")
            completion(.noData)
            return
        }

        // Cold-launch guard — a background-launched silent push races the splash and
        // can deadlock the main queue if the session isn't loaded yet.
        if UserSessionManager.shared.currentUser == nil {
            log(.info, .push, "silent push skipped: cold launch (session not loaded)")
            completion(.noData)
            return
        }

        log(.info, .push, "silent push received — refreshing widgets")

        // 25s safety net (Apple budget 30s − 5s buffer); DispatchWorkItem so an early
        // completion cancels the timer. fireOnce guards against a double call.
        var completionFired = false
        let completionLock = NSLock()
        let fireOnce: (UIBackgroundFetchResult, String) -> Void = { result, source in
            completionLock.lock()
            defer { completionLock.unlock() }
            guard !completionFired else { return }
            completionFired = true
            log(.success, .push, "silent push complete (\(source))")
            completion(result)
        }

        let timeoutItem = DispatchWorkItem {
            fireOnce(.newData, "25s timeout safety net")
        }
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 25, execute: timeoutItem)

        WidgetSyncService.shared.sync(
            kinds: Set(WidgetSyncKind.allCases),
            reason: .silentPush
        ) { _ in
            timeoutItem.cancel()
            fireOnce(.newData, "sync completion")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationManager: UNUserNotificationCenterDelegate {

    // App foreground: still show the banner so the user sees the event.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // Banner tap → deep link. Payload carries a route type under "t"; map it onto the
    // app's URL scheme and let DeepLinkRouter handle host allowlisting + cold-launch.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }

        let userInfo = response.notification.request.content.userInfo
        guard let type = userInfo["t"] as? String,
              let url = URL(string: "appseed://\(type)") else { return }

        log(.info, .push, "banner tap routing: \(url.absoluteString)")
        DispatchQueue.main.async {
            DeepLinkRouter.shared.handle(url: url)
        }
    }
}
