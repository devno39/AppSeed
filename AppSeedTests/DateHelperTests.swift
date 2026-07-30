//
//  DateHelperTests.swift
//  AppSeedTests
//
//  Created by Claude on 29.07.2026.
//

import XCTest
@testable import AppSeed

final class DateHelperTests: XCTestCase {

    private let helper = DateHelper.shared
    private let calendar = Calendar.current

    // MARK: - Helpers
    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    // MARK: - Next Occurrence
    func testYearlyOccurrenceStaysInThisYearWhenStillAhead() {
        let today = date(2026, 3, 1)
        let anniversary = date(2020, 6, 15)

        let next = helper.nextOccurrence(of: anniversary, period: .yearly, from: today)

        XCTAssertEqual(calendar.component(.year, from: next), 2026)
        XCTAssertEqual(calendar.component(.month, from: next), 6)
        XCTAssertEqual(calendar.component(.day, from: next), 15)
    }

    func testYearlyOccurrenceRollsToNextYearOncePassed() {
        let today = date(2026, 9, 1)
        let anniversary = date(2020, 6, 15)

        let next = helper.nextOccurrence(of: anniversary, period: .yearly, from: today)

        XCTAssertEqual(calendar.component(.year, from: next), 2027)
    }

    func testMonthlyOccurrenceRollsToNextMonthOncePassed() {
        let today = date(2026, 3, 20)
        let source = date(2026, 1, 10)

        let next = helper.nextOccurrence(of: source, period: .monthly, from: today)

        XCTAssertEqual(calendar.component(.month, from: next), 4)
        XCTAssertEqual(calendar.component(.day, from: next), 10)
    }

    // MARK: - Days Remaining
    func testDaysRemainingCountsForward() {
        let target = calendar.date(byAdding: .day, value: 5, to: helper.startOfDay(Date()))!

        XCTAssertEqual(helper.daysRemaining(from: target, period: .none), 5)
    }

    func testDaysRemainingIsNegativeForPastOneOffDates() {
        let target = calendar.date(byAdding: .day, value: -3, to: helper.startOfDay(Date()))!

        XCTAssertEqual(helper.daysRemaining(from: target, period: .none), -3)
    }

    // MARK: - Occurrence Days
    // The trap this locks down: Feb 29 in a non-leap year resolves forward to Mar 1, and the
    // month grid must agree with nextOccurrence about where it landed.
    func testLeapDayYearlyOccurrenceRollsForwardInNonLeapYear() {
        let leapDay = date(2024, 2, 29)

        XCTAssertEqual(helper.occurrenceDays(of: leapDay, period: .yearly, in: date(2026, 2, 1)), [])
        XCTAssertEqual(helper.occurrenceDays(of: leapDay, period: .yearly, in: date(2026, 3, 1)), [1])
    }

    func testLeapDayYearlyOccurrenceStaysOn29InLeapYear() {
        let leapDay = date(2024, 2, 29)

        XCTAssertEqual(helper.occurrenceDays(of: leapDay, period: .yearly, in: date(2028, 2, 1)), [29])
    }

    func testNonRecurringOccurrenceOnlyAppearsInItsOwnMonth() {
        let oneOff = date(2026, 5, 12)

        XCTAssertEqual(helper.occurrenceDays(of: oneOff, period: .none, in: date(2026, 5, 1)), [12])
        XCTAssertEqual(helper.occurrenceDays(of: oneOff, period: .none, in: date(2026, 6, 1)), [])
    }

    func testOccurrenceNeverAppearsBeforeItsSourceDate() {
        let source = date(2026, 5, 12)

        XCTAssertEqual(helper.occurrenceDays(of: source, period: .yearly, in: date(2025, 5, 1)), [])
    }
}
