//
//  SceneDelegate.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private static var lastReconcileAt: Date?
    private static let reconcileWindow: TimeInterval = 30

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        setInitialScene(with: windowScene)
        DeepLinkRouter.shared.capture(from: connectionOptions)
    }

    // MARK: - Deep Links
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        log(.info, .general, "Scene openURLContexts: \(url.absoluteString)")
        DeepLinkRouter.shared.handle(url: url)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Visible pushes carry badge:1 — clear on every activation.
        UNUserNotificationCenter.current().setBadgeCount(0)

        let session = UserSessionManager.shared
        session.updateLastSeen()

        if let last = Self.lastReconcileAt, Date().timeIntervalSince(last) < Self.reconcileWindow {
            return
        }
        Self.lastReconcileAt = Date()

        // Catches background changes the realtime channel may have missed.
        session.refreshUser()
    }

    // MARK: - Initial Scene
    private func setInitialScene(with windowScene: UIWindowScene) {
        let splashViewController = SplashBuilder().build()
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = splashViewController
        window?.overrideUserInterfaceStyle = ThemeManager.shared.currentTheme.userInterfaceStyle
        window?.makeKeyAndVisible()
    }

    // MARK: - Set to Window
    static func setToWindow(_ viewController: UIViewController) {
        guard let sceneDelegate = UIApplication.shared.sceneDelegate,
              let window = sceneDelegate.window else {
            log(.error, .general, "Unable to access SceneDelegate's window")
            return
        }

        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: { window.rootViewController = viewController },
            completion: { _ in
                // Drain a pending deep link once the tab bar is root; splash → login
                // swaps preserve the URL until then.
                guard viewController is UITabBarController else { return }
                DeepLinkRouter.shared.drainPending()
            }
        )
        window.makeKeyAndVisible()
    }
}
