//
//  BaseTabbarController.swift
//  AppSeed
//
//  Created by tunay alver on 10.08.2023.
//

import UIKit

class BaseTabbarController: UITabBarController, UITabBarControllerDelegate {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
        delegate = self
    }

    // MARK: - Prepare
    func prepare() {
        let appearance = UITabBarAppearance()

        // iOS 26 Liquid Glass auto-applies on transparent; pre-26 needs the default backdrop blur for legibility.
        if #available(iOS 26, *) {
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
        } else {
            appearance.configureWithDefaultBackground()
        }

        appearance.shadowColor = .clear
        appearance.shadowImage = nil

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        tabBar.isTranslucent = true
        if #available(iOS 26, *) {
            tabBar.backgroundColor = .clear
            tabBar.backgroundImage = UIImage()
        }
        tabBar.shadowImage = UIImage()
    }
}

// MARK: - Delegate
extension BaseTabbarController {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
}
