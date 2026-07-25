//
//  TabBarBuilder.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class TabBarBuilder: BaseBuilder {
    func build() -> UIViewController {
        let router = TabBarRouter()
        let viewModel = TabBarViewModel()
        let viewController = TabBarViewController(viewModel: viewModel, router: router)

        return viewController
    }
}
