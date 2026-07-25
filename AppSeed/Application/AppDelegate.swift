//
//  AppDelegate.swift
//  AppSeed
//
//  Created by tunay alver on 5.01.2025.
//

import UIKit
import Firebase
import FirebaseCore
import RevenueCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        LanguageHelper.setAppLanguage()
        IAPHelper.shared.configure()
        firebase()
        supabase()
        return true
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
