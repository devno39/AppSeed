//
//  AppDelegate.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setInitialScene()
        return true
    }
    
    //MARK: - Initial Scene
    private func setInitialScene() {
        let splashViewController = SplashRouter().create()
        let navigationController = BaseNavigationController(rootViewController: splashViewController)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

