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
        SceneDelegate.setToWindow(vc)
    }
}

// MARK: - Router
final class TutorialRouter: BaseRouter, ScrollTestRoute { }
