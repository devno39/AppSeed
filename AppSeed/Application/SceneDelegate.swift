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
            animations: { window.rootViewController = viewController }
        )
        window.makeKeyAndVisible()
    }
}
