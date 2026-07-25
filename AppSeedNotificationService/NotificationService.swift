//
//  NotificationService.swift
//  AppSeedNotificationService
//
//  Created by Claude on 26.07.2026.
//

import UserNotifications
#if canImport(WidgetKit)
import WidgetKit
#endif

// Notification Service Extension.
//
// Wakes for every APNs push Apple delivers — including when the main
// app is force-quit. That's the whole point of this extension: force-
// quit silent pushes are dropped (Apple rule), but visible pushes with
// mutable-content=1 route through the NSE first, so the app's widgets
// can refresh even when the main binary is not running.
//
// What this extension does:
//   1. Validate payload protocol version (payload_version: 2 for visible
//      pushes). Silent pushes (payload_version: 1) never reach the NSE —
//      they have no mutable-content: 1 flag.
//   2. Ask WidgetKit to reload all widget timelines. The widget extension
//      reads the existing App Group snapshot written by the most recent
//      foreground main-app sync — stale data is possible here, but the
//      banner still lets the user tap into the main app, which then runs
//      a fresh foreground reconcile.
//   3. Pass the notification content through as-is. The server already set
//      title-loc-key + loc-args, and UserNotifications localizes the title
//      at display time using the app's Localizable.strings — so no user
//      data ever lands in the payload itself.
//   4. 25s safety net via serviceExtensionTimeWillExpire — Apple gives the
//      extension up to 30s; we fire contentHandler before then.
//
// NOT done here:
//   - No backend client, no RPCs, no fresh data fetch. The NSE has no auth
//     session, and reaching the network adds budget risk. The main app's
//     foreground reconcile handles the fresh-data pull when the user opens
//     the app.
class NotificationService: UNNotificationServiceExtension {

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent

        guard let bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        let userInfo = request.content.userInfo

        // Only act on our visible protocol; silent pushes (payload_version: 1)
        // do not pass through the NSE because they have no mutable-content: 1 flag.
        let version = userInfo["payload_version"] as? Int ?? 0
        guard version == 2 else {
            contentHandler(bestAttemptContent)
            return
        }

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif

        contentHandler(bestAttemptContent)
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
