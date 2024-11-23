//
//  RouterTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit

// MARK: - Route Protocol
protocol TutorialRoute {
    func showTutorail()
}

extension TutorialRoute where Self: BaseRouterProtocol {
    func showTutorail() {
        let vc = TutorialBuilder().build()
        let window = UIApplication.appDelegate?.window
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

// MARK: - Router
final class TutorialRouter: BaseRouter { }
