//
//  LocalReminderHelper.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import Foundation
import UserNotifications

enum ReminderRepeatRule {
    case none
    case daily
    case weekly
    case monthly
    case yearly
}

struct LocalReminder {
    let id: String
    let title: String
    let body: String
    let date: Date
    let repeatRule: ReminderRepeatRule
    let minutesIntoDay: Int?
    let userInfo: [String: String]

    init(
        id: String,
        title: String,
        body: String,
        date: Date,
        repeatRule: ReminderRepeatRule = .none,
        minutesIntoDay: Int? = nil,
        userInfo: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.date = date
        self.repeatRule = repeatRule
        self.minutesIntoDay = minutesIntoDay
        self.userInfo = userInfo
    }
}

struct LocalReminderHelper {

    // MARK: - Constants
    static let defaultMinutesIntoDay = 12 * 60

    // MARK: - Sync
    // Dropping the previous generation by identifier prefix removes per-item bookkeeping.
    static func sync(prefix: String, reminders: [LocalReminder]) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            let obsolete = pending
                .filter { $0.identifier.hasPrefix(prefix) }
                .map(\.identifier)

            if obsolete.isNotEmpty {
                center.removePendingNotificationRequests(withIdentifiers: obsolete)
            }

            reminders.forEach { schedule($0, prefix: prefix) }
        }
    }

    static func cancelAll(prefix: String) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            let identifiers = pending
                .filter { $0.identifier.hasPrefix(prefix) }
                .map(\.identifier)
            guard identifiers.isNotEmpty else { return }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    // MARK: - Private
    private static func schedule(_ reminder: LocalReminder, prefix: String) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        content.userInfo = reminder.userInfo

        let request = UNNotificationRequest(
            identifier: "\(prefix)\(reminder.id)",
            content: content,
            trigger: trigger(for: reminder)
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                log(.error, .notification, "Failed to schedule \(reminder.id): \(error.localizedDescription)")
            }
        }
    }

    static func trigger(for reminder: LocalReminder) -> UNCalendarNotificationTrigger {
        let minutes = reminder.minutesIntoDay ?? defaultMinutesIntoDay
        let calendar = Calendar.current
        let source = calendar.dateComponents([.year, .month, .day, .weekday], from: reminder.date)

        var components = DateComponents()
        components.hour = minutes / 60
        components.minute = minutes % 60

        switch reminder.repeatRule {
        case .none:
            components.year = source.year
            components.month = source.month
            components.day = source.day
        case .daily:
            break
        case .weekly:
            components.weekday = source.weekday
        case .monthly:
            components.day = source.day
        case .yearly:
            components.month = source.month
            components.day = source.day
        }

        return UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: reminder.repeatRule != .none
        )
    }
}
