//
//  SetupFlowRouter.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol SetupFlowRoute {
    func presentSetupFlow(onComplete: EmptyClosure?)
}

extension SetupFlowRoute where Self: BaseRouter {
    func presentSetupFlow(onComplete: EmptyClosure? = nil) {
        let vc = SetupFlowBuilder(onComplete: onComplete).build()
        vc.modalPresentationStyle = .overFullScreen
        viewController?.present(vc, animated: false)
    }
}

// MARK: - Router
final class SetupFlowRouter: BaseRouter, FormBottomSheetRoute { }
