//
//  UIApplication+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

extension UIApplication {
    var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var sceneDelegate: SceneDelegate? {
        connectedScenes
            .first { $0.activationState == .foregroundActive }
            .flatMap { $0.delegate as? SceneDelegate }
    }

    static let appVersion: String = {
        if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return appVersion
        } else {
            return ""
        }
    }()

    static let appBuild: String = {
        if let appBuild = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
            return appBuild
        } else {
            return ""
        }
    }()

    static func appVersionAndBuild() -> String {
        let releaseVersion = "v. " + appVersion
        let buildVersion = " b. " + appBuild
        return Configuration.isRelease ? releaseVersion : releaseVersion + buildVersion
    }
    
    func topMostViewController() -> UIViewController? {
        return rootWindow()?.rootViewController?.topMostViewController()
    }
    
    func rootWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first { $0.rootViewController is UITabBarController }
    }
    
    func keyWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first { $0.isKeyWindow }
    }
    
    func openApplicationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL((url)) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
