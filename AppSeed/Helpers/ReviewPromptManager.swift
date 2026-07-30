//
//  ReviewPromptManager.swift
//  AppSeed
//
//  Created by Claude on 03.06.2026.
//

import UIKit
import StoreKit

enum ReviewPromptManager {

    // MARK: - Tracking
    static func incrementSession() {
        UserDefaultsWrapper.review_session_count += 1
    }

    static func recordMilestone() {
        guard UserDefaultsWrapper.review_milestone_session_index == 0 else { return }
        UserDefaultsWrapper.review_milestone_session_index = UserDefaultsWrapper.review_session_count
    }

    // The shown flag survives this reset — re-reaching the milestone must not re-ask.
    static func clearMilestoneTracking() {
        UserDefaultsWrapper.review_milestone_session_index = 0
    }

    // MARK: - Gate
    private static let sessionsAfterMilestone = 2

    static func shouldShow() -> Bool {
        let milestoneSession = UserDefaultsWrapper.review_milestone_session_index
        guard milestoneSession > 0 else { return false }
        guard UserDefaultsWrapper.review_shown_count == 0 else { return false }
        return UserDefaultsWrapper.review_session_count - milestoneSession >= sessionsAfterMilestone
    }

    static func markShown() {
        UserDefaultsWrapper.review_shown_count += 1
    }

    // MARK: - Apple Review
    static func requestAppleReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
