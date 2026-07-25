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

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        configureTabBar()
        observeChanges()
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
    }

    @objc private func handleLanguageChange() {
        guard let vcs = viewControllers else { return }
        let titles = [TabBarLocalizable.home]
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

        // Phase 3B adds Profile tab
        viewControllers = [homeNav]
    }

    private func configureTabBar() {
        tabBar.tintColor = Palette.palette1.color
        tabBar.unselectedItemTintColor = ColorText.textSecondary.color
    }
}
