//
//  NotificationHelper.swift
//  AppSeed
//
//  Created by tunay alver on 13.07.2025.
//

import UserNotifications

struct NotificationHelper {

    // MARK: - Legacy Identifiers
    // Kept so clearScheduledReminders() can purge the pre-2026 prototype's "id_1" repeating notification.
    private static let legacyIdentifiers = ["id_1"]

    // MARK: - Authorization
    static func requestAuthorization(completion: BoolClosure? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                log(.success, .notification, "Notification permission granted")
                completion?(true)
            } else {
                log(.warning, .notification, "Notification permission denied")
                completion?(false)
            }
        }
    }

    // MARK: - Demo Scheduler
    // Repeating local notification at a fixed wall-clock time — a template for daily reminders.
    static func scheduleDailyReminderDemo(hour: Int, minute: Int, title: String, body: String) {
        let identifier = "daily_reminder_demo"

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.add(request) { error in
            if let error {
                log(.error, .notification, "Failed to schedule \(identifier): \(error.localizedDescription)")
            } else {
                log(.success, .notification, "Scheduled \(identifier) daily at \(hour):\(minute)")
            }
        }
    }

    // MARK: - Cleanup
    static func clearScheduledReminders() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: legacyIdentifiers)
        center.removeDeliveredNotifications(withIdentifiers: legacyIdentifiers)
        log(.info, .notification, "Cleared legacy scheduled notifications: \(legacyIdentifiers)")
    }
}
