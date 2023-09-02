//
//  BaseRouter.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

protocol BaseRouterProtocol { }

class BaseRouter: Navigator {
    override func create() -> UIViewController {
        let viewModel = BaseViewModel<BaseRouter, Any>(router: self)
        let viewController = BaseViewController(viewModel: viewModel)
        return viewController
    }
    
    override func createWithNavigation() -> UIViewController {
        BaseNavigationController(rootViewController: create())
    }
}
