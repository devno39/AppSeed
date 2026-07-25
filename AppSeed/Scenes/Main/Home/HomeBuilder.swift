//
//  HomeBuilder.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class HomeBuilder: BaseBuilder {
    func build() -> UIViewController {
        let router = HomeRouter()
        let viewModel = HomeViewModel()
        let viewController = HomeViewController(viewModel: viewModel, router: router)

        return viewController
    }
}
