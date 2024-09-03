//
//  SplashRouter.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

final class SplashRouter: BaseRouter {
    override func create() -> UIViewController {
        let viewModel = SplashViewModel(router: self)
        let viewController = SplashViewController(viewModel: viewModel)
        return viewController
    }
    
    func pushToHome() {
        
    }
}
