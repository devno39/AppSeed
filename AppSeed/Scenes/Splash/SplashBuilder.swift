//
//  SplashBuilder.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit

class SplashBuilder: BaseBuilder {
    func build() -> UIViewController {
        let viewModel = SplashViewModel()
        let router = SplashRouter()
        let viewController = SplashViewController(viewModel: viewModel, router: router)

        return viewController
    }
}
