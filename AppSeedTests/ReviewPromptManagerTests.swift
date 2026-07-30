//
//  ReviewPromptManagerTests.swift
//  AppSeedTests
//
//  Created by Claude on 29.07.2026.
//

import XCTest
@testable import AppSeed

final class ReviewPromptManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        reset()
    }

    override func tearDown() {
        reset()
        super.tearDown()
    }

    private func reset() {
        UserDefaultsWrapper.review_session_count = 0
        UserDefaultsWrapper.review_milestone_session_index = 0
        UserDefaultsWrapper.review_shown_count = 0
    }

    // MARK: - Gate
    func testDoesNotAskBeforeTheMilestone() {
        (0..<10).forEach { _ in ReviewPromptManager.incrementSession() }

        XCTAssertFalse(ReviewPromptManager.shouldShow())
    }

    func testDoesNotAskOnTheSessionThatReachedTheMilestone() {
        ReviewPromptManager.incrementSession()
        ReviewPromptManager.recordMilestone()

        XCTAssertFalse(ReviewPromptManager.shouldShow())
    }

    func testAsksTwoSessionsAfterTheMilestone() {
        ReviewPromptManager.incrementSession()
        ReviewPromptManager.recordMilestone()
        ReviewPromptManager.incrementSession()

        XCTAssertFalse(ReviewPromptManager.shouldShow(), "one session later is too early")

        ReviewPromptManager.incrementSession()

        XCTAssertTrue(ReviewPromptManager.shouldShow())
    }

    func testNeverAsksTwice() {
        ReviewPromptManager.incrementSession()
        ReviewPromptManager.recordMilestone()
        ReviewPromptManager.incrementSession()
        ReviewPromptManager.incrementSession()
        ReviewPromptManager.markShown()

        (0..<20).forEach { _ in ReviewPromptManager.incrementSession() }

        XCTAssertFalse(ReviewPromptManager.shouldShow())
    }

    // MARK: - Milestone
    func testMilestoneIsRecordedOnlyOnce() {
        ReviewPromptManager.incrementSession()
        ReviewPromptManager.recordMilestone()
        let first = UserDefaultsWrapper.review_milestone_session_index

        ReviewPromptManager.incrementSession()
        ReviewPromptManager.recordMilestone()

        XCTAssertEqual(UserDefaultsWrapper.review_milestone_session_index, first)
    }

    // The shown flag has to survive sign-out, otherwise a re-signed-in user is asked again.
    func testClearingMilestoneKeepsTheShownFlag() {
        ReviewPromptManager.markShown()
        ReviewPromptManager.clearMilestoneTracking()

        XCTAssertEqual(UserDefaultsWrapper.review_milestone_session_index, 0)
        XCTAssertEqual(UserDefaultsWrapper.review_shown_count, 1)

        ReviewPromptManager.incrementSession()
        ReviewPromptManager.recordMilestone()
        ReviewPromptManager.incrementSession()
        ReviewPromptManager.incrementSession()

        XCTAssertFalse(ReviewPromptManager.shouldShow())
    }
}
