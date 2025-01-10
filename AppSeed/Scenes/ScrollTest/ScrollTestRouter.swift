//
//  RouterTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit

// MARK: - Route Protocol
protocol ScrollTestRoute {
    func presentScrollTest()
}

extension ScrollTestRoute where Self: BaseRouterProtocol {
    func presentScrollTest() {
        let vc = ScrollTestBuilder().build()
        let nc = BaseNavigationController(rootViewController: vc)
        SceneDelegate.setToWindow(nc)
    }
}

// MARK: - Router
final class ScrollTestRouter: BaseRouter { }
