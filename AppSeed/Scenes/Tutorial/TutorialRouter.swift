//
//  RouterTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit

// MARK: - Route Protocol
protocol TutorialRoute {
    func showTutorial()
}

extension TutorialRoute where Self: BaseRouter {
    func showTutorial() {
        let vc = TutorialBuilder().build()
        let window = UIApplication.appDelegate?.window
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            window.rootViewController = vc
        }
        window.makeKeyAndVisible()
    }
}

// MARK: - Router
final class TutorialRouter: BaseRouter { }
