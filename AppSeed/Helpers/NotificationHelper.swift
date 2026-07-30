//
//  NotificationHelper.swift
//  AppSeed
//
//  Created by tunay alver on 13.07.2025.
//

import UserNotifications

struct NotificationHelper {

    // MARK: - Authorization
    static func requestAuthorization(completion: BoolClosure? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                log(.success, .notification, "Notification permission granted")
                completion?(true)
            } else {
                log(.warning, .notification, "Notification permission denied")
                completion?(false)
            }
        }
    }
}
