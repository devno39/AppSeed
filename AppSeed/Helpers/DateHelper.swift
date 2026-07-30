//
//  DateHelper.swift
//  AppSeed
//
//  Created by Codex on 22.02.2026.
//

import Foundation

enum DateFormat: String {
    case standard = "yyyy-MM-dd"
    case dayDotMonthDotYear = "dd.MM.yyyy"
    case monthSlashDaySlashYear = "MM/dd/yyyy"
    case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ"
    case monthYear = "MMMM yyyy"
    case dayMonthYear = "d MMMM yyyy"
    case weekdayMonthDay = "EEEE, d MMMM"
    case short = "d MMM"
    case time = "HH:mm"
    case dayMonth = "d MMMM"
    case monthDay = "MMMM d"
}

enum RecurrencePeriod: String, Codable {
    case none
    case yearly
    case monthly
}

final class DateHelper {

    static let shared = DateHelper()
    private let calendar = Calendar.current

    private init() {}

    // MARK: - Formatter Cache
    // One formatter per (language, format) — per-call allocation janks echo-driven re-renders.
    // Background sync handlers read these too: creation is lock-guarded and formatters stay
    // immutable after creation (DateFormatter reads are thread-safe).
    private let cacheLock = NSLock()
    private var formatterCache: [String: DateFormatter] = [:]

    func formatter(_ dateFormat: String) -> DateFormatter {
        let key = "\(LanguageManager.shared.currentLanguage.rawValue)|\(dateFormat)"
        cacheLock.lock()
        defer { cacheLock.unlock() }
        if let cached = formatterCache[key] { return cached }
        let formatter = DateFormatter()
        formatter.locale = LanguageManager.shared.appLocale
        formatter.dateFormat = dateFormat
        formatterCache[key] = formatter
        return formatter
    }

    // Device-locale 12/24h clock, per-timezone cache.
    func timeString(timeZone: TimeZone) -> String {
        let key = "time|\(timeZone.identifier)"
        cacheLock.lock()
        let formatter: DateFormatter
        if let cached = formatterCache[key] {
            formatter = cached
        } else {
            formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            formatter.timeZone = timeZone
            formatterCache[key] = formatter
        }
        cacheLock.unlock()
        return formatter.string(from: Date())
    }

    // MARK: - Formatting

    func monthName(for date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = locale
        return formatter.string(from: date)
    }

    func year(for date: Date) -> Int {
        let components = calendar.dateComponents([.year], from: date)
        return components.year ?? 0
    }

    func dateString(from date: Date, format: DateFormat = .standard, locale: Locale? = nil) -> String {
        if let locale {
            let formatter = DateFormatter()
            formatter.dateFormat = format.rawValue
            formatter.locale = locale
            return formatter.string(from: date)
        }
        return formatter(format.rawValue).string(from: date)
    }

    // MARK: - Calendar Calculations

    func daysInMonth(for date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }

    func firstDayOfMonth(for date: Date) -> Int {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let firstDay = calendar.date(from: components) else { return 0 }
        return calendar.component(.weekday, from: firstDay) - 1
    }

    func date(forDay day: Int, month: Date) -> Date {
        var components = calendar.dateComponents([.year, .month], from: month)
        components.day = day
        return calendar.date(from: components) ?? month
    }

    // MARK: - Date Arithmetic

    func addMonth(to date: Date, value: Int) -> Date {
        return calendar.date(byAdding: .month, value: value, to: date) ?? date
    }

    func addDay(to date: Date, value: Int) -> Date {
        return calendar.date(byAdding: .day, value: value, to: date) ?? date
    }

    func addWeek(to date: Date, value: Int) -> Date {
        return calendar.date(byAdding: .weekOfYear, value: value, to: date) ?? date
    }

    func addYear(to date: Date, value: Int) -> Date {
        return calendar.date(byAdding: .year, value: value, to: date) ?? date
    }

    // MARK: - Date Comparison

    func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }

    func isDate(_ date1: Date, inSameMonthAs date2: Date) -> Bool {
        let components1 = calendar.dateComponents([.year, .month], from: date1)
        let components2 = calendar.dateComponents([.year, .month], from: date2)
        return components1.year == components2.year && components1.month == components2.month
    }

    func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    func isDate(_ date: Date, between start: Date, and end: Date) -> Bool {
        return date >= start && date <= end
    }

    // MARK: - Date Components

    func day(of date: Date) -> Int {
        return calendar.component(.day, from: date)
    }

    func month(of date: Date) -> Int {
        return calendar.component(.month, from: date)
    }

    func weekOfYear(of date: Date) -> Int {
        return calendar.component(.weekOfYear, from: date)
    }

    // MARK: - Utilities

    func startOfDay(_ date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }

    func endOfDay(_ date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfDay(date)) ?? date
    }

    // MARK: - Year, Month, Day Calculation

    func yearMonthDay(from start: Date, to end: Date) -> (years: Int, months: Int, days: Int) {
        let components = calendar.dateComponents([.year, .month, .day], from: start, to: end)
        return (components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    // MARK: - Recurring Events

    func daysRemaining(from date: Date, period: RecurrencePeriod) -> Int {
        let today = startOfDay(Date())

        switch period {
        case .none:
            return calendar.dateComponents([.day], from: today, to: startOfDay(date)).day ?? 0

        case .yearly, .monthly:
            let nextDate = nextOccurrence(of: date, period: period, from: today)
            return calendar.dateComponents([.day], from: today, to: nextDate).day ?? 0
        }
    }

    func nextOccurrence(of date: Date, period: RecurrencePeriod, from today: Date) -> Date {
        let components = calendar.dateComponents([.month, .day], from: date)
        let currentYear = calendar.component(.year, from: today)
        let currentMonth = calendar.component(.month, from: today)

        switch period {
        case .none:
            return startOfDay(date)

        case .yearly:
            var thisYearComponents = DateComponents()
            thisYearComponents.year = currentYear
            thisYearComponents.month = components.month
            thisYearComponents.day = components.day

            guard let thisYearDate = calendar.date(from: thisYearComponents) else { return today }
            let thisYearStart = startOfDay(thisYearDate)
            guard thisYearStart < today else { return thisYearStart }

            var nextYearComponents = DateComponents()
            nextYearComponents.year = currentYear + 1
            nextYearComponents.month = components.month
            nextYearComponents.day = components.day
            return calendar.date(from: nextYearComponents).map(startOfDay) ?? today

        case .monthly:
            var thisMonthComponents = DateComponents()
            thisMonthComponents.year = currentYear
            thisMonthComponents.month = currentMonth
            thisMonthComponents.day = components.day

            guard let thisMonthDate = calendar.date(from: thisMonthComponents) else { return today }
            let thisMonthStart = startOfDay(thisMonthDate)
            guard thisMonthStart < today else { return thisMonthStart }

            guard let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: thisMonthDate) else { return today }
            return startOfDay(nextMonthDate)
        }
    }

    // Resolves overflow the same way nextOccurrence does (Feb 29 → Mar 1), so a grid and
    // a list can never disagree on where an occurrence lands.
    func occurrenceDays(of date: Date, period: RecurrencePeriod, in month: Date) -> [Int] {
        let original = startOfDay(date)
        let displayed = calendar.dateComponents([.year, .month], from: month)
        guard let displayedYear = displayed.year, let displayedMonth = displayed.month else { return [] }
        let originalComponents = calendar.dateComponents([.month, .day], from: date)

        func dayIfInDisplayedMonth(year: Int, month: Int, day: Int?) -> Int? {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            guard let resolved = calendar.date(from: components), startOfDay(resolved) >= original else { return nil }
            let resolvedComponents = calendar.dateComponents([.year, .month, .day], from: resolved)
            guard resolvedComponents.year == displayedYear, resolvedComponents.month == displayedMonth else { return nil }
            return resolvedComponents.day
        }

        switch period {
        case .none:
            guard isDate(date, inSameMonthAs: month) else { return [] }
            return [day(of: date)]

        case .yearly:
            return dayIfInDisplayedMonth(
                year: displayedYear,
                month: originalComponents.month ?? 1,
                day: originalComponents.day
            ).map { [$0] } ?? []

        case .monthly:
            let candidates = [
                dayIfInDisplayedMonth(year: displayedYear, month: displayedMonth, day: originalComponents.day),
                dayIfInDisplayedMonth(year: displayedYear, month: displayedMonth - 1, day: originalComponents.day)
            ]
            return Array(Set(candidates.compactMap { $0 })).sorted()
        }
    }
}
