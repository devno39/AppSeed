//
//  PermissionPromptManager.swift
//  AppSeed
//
//  Created by Claude on 26.08.2026.
//

import Foundation

enum PermissionPromptManager {

    // MARK: - Schedule
    // One entry per showing, each the number of sessions to wait first.
    private static let gaps = [0, 3, 6]

    // MARK: - Gate
    static func shouldShow() -> Bool {
        let shownCount = UserDefaultsWrapper.permission_sheet_shown_count
        guard !PermissionManager.shared.allGranted,
              gaps.indices.contains(shownCount) else { return false }

        let elapsed = UserDefaultsWrapper.review_session_count - UserDefaultsWrapper.permission_sheet_last_session
        return elapsed >= gaps[shownCount]
    }

    // Tied to shouldShow, never to "has it been shown": a presentation that never lands would
    // otherwise leave What's New and the paywall queued behind it forever.
    static var isSettled: Bool { !shouldShow() }

    // MARK: - Tracking
    static func markShown() {
        UserDefaultsWrapper.permission_sheet_last_session = UserDefaultsWrapper.review_session_count
        UserDefaultsWrapper.permission_sheet_shown_count += 1
    }

    static func reset() {
        UserDefaultsWrapper.permission_sheet_shown_count = 0
        UserDefaultsWrapper.permission_sheet_last_session = 0
    }
}
