//
//  SplashBuilder.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit

final class SplashBuilder: BaseBuilder {
    func build() -> UIViewController {
        let viewModel = SplashViewModel(userService: SupabaseUserService())
        let router = SplashRouter()
        let viewController = SplashViewController(viewModel: viewModel, router: router)

        return viewController
    }
}
