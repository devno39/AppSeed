//
//  LoginRouter.swift
//  AppSeed
//
//  Created by Claude on 19.01.2025.
//

import UIKit

// MARK: - Route Protocol
protocol LoginRoute {
    func showLogin()
}

extension LoginRoute where Self: BaseRouter {
    func showLogin() {
        let vc = LoginBuilder().build()
        SceneDelegate.setToWindow(vc)
    }
}

final class LoginRouter: BaseRouter, LoginRoute, TabBarRoute { }
