//
//  TabBarViewController.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class TabBarViewController: BaseTabbarController {

    // MARK: - Dependency
    private var viewModel: TabBarViewModel?
    private var router: TabBarRouter?

    // MARK: - Init
    init(viewModel: TabBarViewModel, router: TabBarRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Properties
    private var isFirstAppear = true
    private var isSetupFlowPresented = false

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        configureTabBar()
        observeChanges()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // currentUser must be loaded before checking fields — triggered here and on userDidChange.
        if UserSessionManager.shared.currentUser != nil {
            presentSetupFlowIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Observers
    private func observeChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLanguageChange),
            name: .languageDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePaletteChange),
            name: .paletteDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserDidChange),
            name: .userDidChange,
            object: nil
        )
    }

    @objc private func handleUserDidChange() {
        guard !isSetupFlowPresented else { return }
        presentSetupFlowIfNeeded()
    }

    @objc private func handleLanguageChange() {
        guard let vcs = viewControllers else { return }
        let titles = [TabBarLocalizable.home, TabBarLocalizable.profile]
        for (index, vc) in vcs.enumerated() where index < titles.count {
            vc.tabBarItem.title = titles[index]
        }
    }

    @objc private func handlePaletteChange() {
        tabBar.tintColor = Palette.palette1.color
    }
}

// MARK: - Setup
extension TabBarViewController {

    private func setupViewControllers() {
        let homeVC = HomeBuilder().build()
        homeVC.tabBarItem = UITabBarItem(title: TabBarLocalizable.home, image: Symbols.house.symbolMedium(), tag: 0)

        let homeNav = BaseNavigationController(rootViewController: homeVC)

        let itemsVC = ItemsBuilder().build()
        itemsVC.tabBarItem = UITabBarItem(title: TabBarLocalizable.items, image: Symbols.checkmark_circle_fill.symbolMedium(), tag: 1)

        let itemsNav = BaseNavigationController(rootViewController: itemsVC)

        let profileVC = ProfileBuilder().build()
        profileVC.tabBarItem = UITabBarItem(title: TabBarLocalizable.profile, image: Symbols.person_crop_circle.symbolMedium(), tag: 2)

        let profileNav = BaseNavigationController(rootViewController: profileVC)

        viewControllers = [homeNav, itemsNav, profileNav]
    }

    private func configureTabBar() {
        tabBar.tintColor = Palette.palette1.color
        tabBar.unselectedItemTintColor = ColorText.textSecondary.color
    }
}

// MARK: - Setup Flow
extension TabBarViewController {

    private func presentSetupFlowIfNeeded() {
        guard isFirstAppear else { return }
        guard let user = UserSessionManager.shared.currentUser else { return }
        isFirstAppear = false

        let hasName = !(user.displayName ?? "").isEmpty
        let hasBirthday = user.birthDate != nil

        // Both fields present — setup is already complete for this account.
        if hasName && hasBirthday {
            UserDefaultsWrapper.has_completed_setup = true
            // An account that skipped the form never stamped a version, and What's New would
            // greet it with notes for an update it did not live through.
            WhatsNewManager.markCurrentVersionSeenIfNeeded()
        }

        guard !UserDefaultsWrapper.has_completed_setup else { return }

        isSetupFlowPresented = true
        router?.presentSetupFlow(onComplete: { [weak self] in
            self?.isSetupFlowPresented = false
        })
    }
}
