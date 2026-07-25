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

    static func clearMilestoneTracking() {
        UserDefaultsWrapper.review_milestone_session_index = 0
        UserDefaultsWrapper.review_shown_count = 0
    }

    // MARK: - Gate
    static func shouldShow() -> Bool {
        let milestoneSession = UserDefaultsWrapper.review_milestone_session_index
        guard milestoneSession > 0 else { return false }
        let shown = UserDefaultsWrapper.review_shown_count
        guard shown < 2 else { return false }
        let sinceMilestone = UserDefaultsWrapper.review_session_count - milestoneSession
        if shown == 0 { return sinceMilestone >= 1 }
        if shown == 1 { return sinceMilestone >= 5 }
        return false
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
