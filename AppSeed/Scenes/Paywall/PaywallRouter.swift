//
//  PaywallRouter.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol PaywallRoute {
    func presentPaywall()
}

extension PaywallRoute where Self: BaseRouter {
    func presentPaywall() {
        let vc = PaywallBuilder().build()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        viewController?.present(vc, animated: true)
    }
}

// MARK: - Router
final class PaywallRouter: BaseRouter {}
