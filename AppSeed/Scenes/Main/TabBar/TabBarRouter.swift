//
//  TabBarRouter.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol TabBarRoute {
    func showTabBar()
}

// MARK: - Route Extension
extension TabBarRoute where Self: BaseRouter {
    func showTabBar() {
        let vc = TabBarBuilder().build()
        SceneDelegate.setToWindow(vc)
    }
}

final class TabBarRouter: BaseRouter, TabBarRoute { }
