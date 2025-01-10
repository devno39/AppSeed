//
//  AppDelegate.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        setInitialScene(with: windowScene)
    }
    
    // MARK: - Initial Scene
    private func setInitialScene(with windowScene: UIWindowScene) {
        let splashViewController = SplashBuilder().build()
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = splashViewController
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Set to Window
    static func setToWindow(_ viewController: UIViewController) {
        guard let sceneDelegate = UIApplication.shared.sceneDelegate,
              let window = sceneDelegate.window else {
            debugPrint("Error: Unable to access SceneDelegate's window.")
            return
        }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
            window.rootViewController = viewController
        }
        window.makeKeyAndVisible()
    }
}
