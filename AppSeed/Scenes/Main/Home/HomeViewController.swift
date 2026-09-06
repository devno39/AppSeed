//
//  HomeViewController.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

final class HomeViewController: BaseViewController<HomeViewModel, HomeRouter> {

    // MARK: - UI
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = Palette.palette1.color
        view.image = Symbols.house.symbol(size: .custom(56), weight: .regular)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorText.textPrimary.color
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorText.textSecondary.color
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        draw()
        registerLaunchPrompts()
    }

    // MARK: - Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // AlertHelper presents asynchronously, so the review gate can't see it coming.
        let hadSharedItem = PendingSharedItem.exists
        handleSharedItem()
        guard !hadSharedItem else { return }
        LaunchPromptManager.shared.presentNextIfPossible()
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSharedItem),
            name: .sharedItemReceived,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOpenPaywallRequested),
            name: .openPaywallRequested,
            object: nil
        )
    }

    // MARK: - Paywall
    @objc private func handleOpenPaywallRequested() {
        guard presentedViewController == nil else { return }
        router?.presentPaywall()
    }

    // MARK: - Share Extension
    // Replace the alert with wherever shared content belongs in the real app.
    @objc private func handleSharedItem() {
        guard let item = PendingSharedItem.consume() else { return }
        AlertHelper.showAlert(
            title: HomeLocalizable.shared_item_title,
            message: item.url ?? item.text
        )
    }

    // MARK: - Launch Prompts
    // The first tab is the app's landing point, so it owns the queue. A scene that lands
    // elsewhere registers there instead — the order itself lives in LaunchPromptManager.
    private func registerLaunchPrompts() {
        // Counted on presentation: counted before it, a dropped present spends a turn unseen.
        LaunchPromptManager.shared.register(.permissions) { [weak self] onDismiss in
            self?.router?.presentPermissionSheet(onDismiss: onDismiss) {
                PermissionPromptManager.markShown()
            }
        }
        LaunchPromptManager.shared.register(.whatsNew) { [weak self] onDismiss in
            self?.presentWhatsNew(onDismiss: onDismiss)
        }
        LaunchPromptManager.shared.register(.review) { [weak self] onDismiss in
            self?.presentReviewPrompt(onDismiss: onDismiss)
        }
        // The paywall is a full screen of its own and reports no dismissal — the next
        // foreground picks the queue back up.
        LaunchPromptManager.shared.register(.onboardingPaywall) { [weak self] _ in
            self?.presentOnboardingPaywall()
        }
        LaunchPromptManager.shared.register(.scheduledPaywall) { [weak self] _ in
            self?.presentScheduledPaywall()
        }
    }

    private func presentWhatsNew(onDismiss: @escaping EmptyClosure) {
        WhatsNewManager.markShown()
        router?.presentBottomSheet(
            title: Localizable.whats_new_title,
            button: BottomSheetButton(title: Localizable.whats_new_button),
            customView: WhatsNewView(items: WhatsNewManager.items),
            onDismiss: onDismiss
        )
    }

    private func presentOnboardingPaywall() {
        UserDefaultsWrapper.onboarding_paywall_shown = true
        PaywallPromptManager.markAnchor()
        router?.presentPaywall()
    }

    private func presentScheduledPaywall() {
        PaywallPromptManager.markScheduledShown()
        router?.presentPaywall()
    }

    private func presentReviewPrompt(onDismiss: @escaping EmptyClosure) {
        ReviewPromptManager.markShown()
        router?.presentReviewPromptSheet(
            onYes: {
                ReviewPromptManager.requestAppleReview()
            },
            onLater: { [weak self] in
                self?.router?.presentFeedbackSheet()
            },
            onDismiss: onDismiss
        )
    }

    // MARK: - Localization
    override func configureLocalization() {
        title = HomeLocalizable.title
        titleLabel.text = HomeLocalizable.title
        subtitleLabel.text = HomeLocalizable.subtitle
    }

    // MARK: - Palette
    override func configurePalette() {
        iconImageView.tintColor = Palette.palette1.color
    }
}

// MARK: - Draw
extension HomeViewController {

    private func draw() {
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-48)
            $0.width.height.equalTo(64)
        }

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(32)
            $0.right.equalToSuperview().offset(-32)
        }

        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(32)
            $0.right.equalToSuperview().offset(-32)
        }
    }
}
