//
//  LocalReminderHelperTests.swift
//  AppSeedTests
//
//  Created by Claude on 29.07.2026.
//

import XCTest
@testable import AppSeed

final class LocalReminderHelperTests: XCTestCase {

    private let calendar = Calendar.current

    private func reminder(
        date: Date,
        rule: ReminderRepeatRule,
        minutesIntoDay: Int? = nil
    ) -> LocalReminder {
        LocalReminder(
            id: "1",
            title: "t",
            body: "b",
            date: date,
            repeatRule: rule,
            minutesIntoDay: minutesIntoDay
        )
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    // MARK: - Fire Time
    func testDefaultFireTimeIsMidday() {
        let trigger = LocalReminderHelper.trigger(for: reminder(date: date(2026, 5, 12), rule: .none))

        XCTAssertEqual(trigger.dateComponents.hour, 12)
        XCTAssertEqual(trigger.dateComponents.minute, 0)
    }

    func testMinutesIntoDayBecomesHourAndMinute() {
        let trigger = LocalReminderHelper.trigger(
            for: reminder(date: date(2026, 5, 12), rule: .none, minutesIntoDay: 9 * 60 + 45)
        )

        XCTAssertEqual(trigger.dateComponents.hour, 9)
        XCTAssertEqual(trigger.dateComponents.minute, 45)
    }

    // MARK: - Repeat Rules
    // Each rule drops the components above its period — that is what makes it repeat.
    func testOneOffCarriesTheFullDate() {
        let trigger = LocalReminderHelper.trigger(for: reminder(date: date(2026, 5, 12), rule: .none))

        XCTAssertFalse(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.year, 2026)
        XCTAssertEqual(trigger.dateComponents.month, 5)
        XCTAssertEqual(trigger.dateComponents.day, 12)
    }

    func testDailyCarriesTimeOnly() {
        let trigger = LocalReminderHelper.trigger(for: reminder(date: date(2026, 5, 12), rule: .daily))

        XCTAssertTrue(trigger.repeats)
        XCTAssertNil(trigger.dateComponents.day)
        XCTAssertNil(trigger.dateComponents.month)
        XCTAssertNil(trigger.dateComponents.year)
    }

    func testWeeklyCarriesWeekdayOnly() {
        let source = date(2026, 5, 12)
        let trigger = LocalReminderHelper.trigger(for: reminder(date: source, rule: .weekly))

        XCTAssertTrue(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.weekday, calendar.component(.weekday, from: source))
        XCTAssertNil(trigger.dateComponents.day)
    }

    func testMonthlyCarriesDayOnly() {
        let trigger = LocalReminderHelper.trigger(for: reminder(date: date(2026, 5, 12), rule: .monthly))

        XCTAssertTrue(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.day, 12)
        XCTAssertNil(trigger.dateComponents.month)
    }

    func testYearlyCarriesMonthAndDay() {
        let trigger = LocalReminderHelper.trigger(for: reminder(date: date(2026, 5, 12), rule: .yearly))

        XCTAssertTrue(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.month, 5)
        XCTAssertEqual(trigger.dateComponents.day, 12)
        XCTAssertNil(trigger.dateComponents.year)
    }
}
