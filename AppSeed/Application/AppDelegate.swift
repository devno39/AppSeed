//
//  AppDelegate.swift
//  AppSeed
//
//  Created by tunay alver on 5.01.2025.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseCore
import RevenueCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppGroupStorage.migrateThemePaletteToSharedDefaultsIfNeeded()
        LanguageHelper.setAppLanguage()
        IAPHelper.shared.configure()
        firebase()
        supabase()
        WidgetSyncService.register([
            DemoWidgetSyncHandler.self
        ])
        // APNs registration runs from UserSessionManager once auth.uid() is available
        // for the device_tokens upsert; here we only claim the delegate.
        UNUserNotificationCenter.current().delegate = PushNotificationManager.shared
        return true
    }

    // MARK: - APNs (Push Notifications)
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        PushNotificationManager.shared.handleDidRegister(deviceToken: deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        PushNotificationManager.shared.handleDidFailToRegister(error: error)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        PushNotificationManager.shared.handleSilentPush(userInfo: userInfo, completion: completionHandler)
    }

    // MARK: - Supabase
    private func supabase() {
        _ = SupabaseManager.shared
        configureDatabaseErrorHandling()
        monitorRealtimeStatus()
    }

    private func monitorRealtimeStatus() {
        let status = SupabaseManager.shared.client.realtimeV2.status
        log(.info, .supabase, "Realtime socket current status: \(status)")

        Task {
            var wasDisconnected = false
            for await status in SupabaseManager.shared.client.realtimeV2.statusChange {
                log(.info, .supabase, "Realtime socket changed: \(status)")
                switch status {
                case .disconnected:
                    wasDisconnected = true
                case .connected where wasDisconnected:
                    wasDisconnected = false
                    await MainActor.run {
                        UserSessionManager.shared.reconcileAfterReconnect()
                    }
                default:
                    break
                }
            }
        }
    }

    private func configureDatabaseErrorHandling() {
        SupabaseDatabaseHelper.errorHandler = { error in
            if let message = SupabaseDatabaseErrorMapper.userMessage(for: error) {
                AlertHelper.showAlert(title: message.title, message: message.message)
            }
        }
    }

    private func firebase() {
        let fileName = (Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String == "Debug")
        ? "GoogleService-Info-develop"
        : "GoogleService-Info-release"
        
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
        }
    }
}
