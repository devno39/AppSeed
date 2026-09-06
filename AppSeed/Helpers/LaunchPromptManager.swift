//
//  LaunchPromptManager.swift
//  AppSeed
//
//  Created by Claude on 23.08.2026.
//

import UIKit

extension Notification.Name {
    static let setupFlowDidComplete = Notification.Name("setupFlowDidComplete")
}

// A prompt reports back when it leaves the screen so the next one can take its turn.
typealias LaunchPromptPresenter = (@escaping EmptyClosure) -> Void

enum LaunchPrompt {
    case permissions
    case whatsNew
    case onboardingPaywall
    case review
    case scheduledPaywall
}

// One owner for everything that wants the screen at launch. Scenes register how to show
// their prompt; the order and the "is it due" rules live here so no prompt can close another.
final class LaunchPromptManager {

    // MARK: - Properties
    static let shared = LaunchPromptManager()

    private var presenters: [LaunchPrompt: LaunchPromptPresenter] = [:]

    // Permissions lead: they are the only door to notifications, location and photos.
    private let order: [LaunchPrompt] = [.permissions, .whatsNew, .onboardingPaywall, .review, .scheduledPaywall]

    // MARK: - Init
    // Setup finishes behind an overFullScreen sheet, so no appearance callback follows it.
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleQueueTrigger), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleQueueTrigger), name: .setupFlowDidComplete, object: nil)
        // Retry for the free user whose paywall turn was skipped while premium was unknown.
        NotificationCenter.default.addObserver(self, selector: #selector(handleQueueTrigger), name: .premiumStatusDidChange, object: nil)
    }

    // MARK: - Observers
    @objc private func handleQueueTrigger() {
        presentNextIfPossible()
    }

    // MARK: - Registration
    func register(_ prompt: LaunchPrompt, presenter: @escaping LaunchPromptPresenter) {
        presenters[prompt] = presenter
    }

    // MARK: - Queue
    // Safe to call as often as you like — every appearance and every foreground is a retry.
    func presentNextIfPossible() {
        guard !UIApplication.shared.isPresentingModally else { return }

        PermissionManager.shared.refreshNotificationStatus { [weak self] in
            guard let self else { return }
            // The async hop above gives another prompt time to take the screen.
            guard !UIApplication.shared.isPresentingModally else { return }

            self.reconcile()
            // A prompt with no registered presenter must not block the ones behind it.
            guard let presenter = self.order.first(where: { self.isDue($0) && self.presenters[$0] != nil })
                .flatMap({ self.presenters[$0] }) else { return }

            presenter { [weak self] in
                self?.presentNextIfPossible()
            }
        }
    }

    // MARK: - Private
    // Prompts that can never apply are settled here instead of blocking the queue forever.
    private func reconcile() {
        if !UserDefaultsWrapper.onboarding_paywall_shown, IAPHelper.shared.isPremium {
            UserDefaultsWrapper.onboarding_paywall_shown = true
        }
    }

    private func isDue(_ prompt: LaunchPrompt) -> Bool {
        guard UserDefaultsWrapper.has_completed_setup else { return false }

        switch prompt {
        case .permissions:
            return PermissionPromptManager.shouldShow()
        case .whatsNew:
            return permissionStepIsSettled && WhatsNewManager.shouldShow()
        case .onboardingPaywall:
            return permissionStepIsSettled
                && !UserDefaultsWrapper.onboarding_paywall_shown
                && IAPHelper.shared.entitlementsKnown
                && !IAPHelper.shared.premiumIncludingLastKnown
        case .review:
            return permissionStepIsSettled && ReviewPromptManager.shouldShow()
        case .scheduledPaywall:
            return permissionStepIsSettled && PaywallPromptManager.shouldShowScheduled()
        }
    }

    private var permissionStepIsSettled: Bool {
        PermissionPromptManager.isSettled
    }
}
