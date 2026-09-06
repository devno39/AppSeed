//
//  PaywallPromptManager.swift
//  AppSeed
//
//  Created by Claude on 15.08.2026.
//

import Foundation

enum PaywallPromptManager {

    // MARK: - Schedule
    private static let gaps = [3, 5, 8]

    // MARK: - Gate
    static func shouldShowScheduled() -> Bool {
        let shownCount = UserDefaultsWrapper.paywall_shown_count
        // A cold launch reads "not premium" until RevenueCat replies.
        guard IAPHelper.shared.entitlementsKnown,
              !IAPHelper.shared.premiumIncludingLastKnown,
              UserDefaultsWrapper.onboarding_paywall_shown,
              gaps.indices.contains(shownCount) else { return false }

        let elapsed = UserDefaultsWrapper.review_session_count - UserDefaultsWrapper.paywall_last_shown_session
        return elapsed >= gaps[shownCount]
    }

    // MARK: - Tracking
    // The onboarding paywall sets the anchor the first gap counts from, without spending one of
    // the scheduled turns.
    static func markAnchor() {
        UserDefaultsWrapper.paywall_last_shown_session = UserDefaultsWrapper.review_session_count
    }

    static func markScheduledShown() {
        markAnchor()
        UserDefaultsWrapper.paywall_shown_count += 1
    }

    static func reset() {
        UserDefaultsWrapper.paywall_last_shown_session = 0
        UserDefaultsWrapper.paywall_shown_count = 0
    }
}
