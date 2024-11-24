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
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

// MARK: - Router
final class TutorialRouter: BaseRouter { }
