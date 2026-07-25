//
//  LoginBuilder.swift
//  AppSeed
//
//  Created by Claude on 19.01.2025.
//

import UIKit

final class LoginBuilder: BaseBuilder {
    func build() -> UIViewController {
        let router = LoginRouter()
        let viewModel = LoginViewModel(appleSignInService: SupabaseAppleSignInService(), userService: SupabaseUserService())
        let viewController = LoginViewController(viewModel: viewModel, router: router)

        return BaseNavigationController(rootViewController: viewController)
    }
}
