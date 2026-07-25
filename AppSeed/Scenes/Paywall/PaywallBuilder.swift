//
//  PaywallBuilder.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class PaywallBuilder: BaseBuilder {
    func build() -> UIViewController {
        let router = PaywallRouter()
        let viewModel = PaywallViewModel()
        let viewController = PaywallViewController(viewModel: viewModel, router: router)
        return viewController
    }
}
