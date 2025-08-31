//
//  NotificationHelper.swift
//  AppSeed
//
//  Created by tunay alver on 13.07.2025.
//

import UserNotifications

struct NotificationHelper {
    enum NotificationType: CaseIterable {
        case id_1
        
        var identifier: String {
            switch self {
            case .id_1:
                return "id_1"
            }
        }
        var title: String {
            switch self {
            case .id_1:
                return "title_1"
            }
        }
        var subtitle: String {
            switch self {
            case .id_1:
                return "subtitle_1"
            }
        }
    }
    
    struct ContentModel {
        let title: String
        let subtitle: String
        
        init(notification: NotificationType) {
            self.title = notification.title
            self.subtitle = notification.subtitle
        }
    }
    
    // MARK: - Properties
    private static let identifiers = NotificationType.allCases.map { $0.identifier }
    
    // MARK: - Intervals
    static func requestAuthorization(completion: BoolClosure? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                log(.success, .notification, "Notification permission granted")
                // Schedule id_1
                scheduleId_1()
                completion?(true)
            } else {
                log(.warning, .notification, "Notification permission denied")
                completion?(false)
            }
        }
    }
    
    static func scheduleId_1() {
        let content = UNMutableNotificationContent()
        let contentModel = ContentModel(notification: .id_1)
        content.title = contentModel.title
        content.body = contentModel.subtitle
        content.sound = .default
        
        // Başlangıç tarihi: bugünden itibaren ilk 12:00
        var nextTriggerDate = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        nextTriggerDate.hour = 12
        nextTriggerDate.minute = 0
        
        // Eğer şu an 12:00'dan sonrayız, bir sonraki güne atla
        if let todayAtNoon = Calendar.current.date(from: nextTriggerDate),
           todayAtNoon < Date() {
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: todayAtNoon) {
                nextTriggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: tomorrow)
            }
        }
        
        // 3 gün aralıkla tekrar edecek şekilde ayarla
        let trigger = UNCalendarNotificationTrigger(dateMatching: nextTriggerDate, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationType.id_1.identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                log(.error, .notification, "Failed to schedule repeat \(NotificationType.id_1.identifier): \(error.localizedDescription)")
            } else {
                log(.success, .notification, "Scheduled repeated notification for \(NotificationType.id_1.identifier) every 3 days at 12:00")
            }
        }
    }
    
    static func clearScheduledReminders() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
        
        let joined = identifiers.joined(separator: ", ")
        log(.info, .notification, "Cleared scheduled notifications: [\(joined)]")
    }
}
