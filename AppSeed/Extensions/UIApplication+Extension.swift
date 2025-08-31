//
//  UIApplication+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit
import StoreKit

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
        return keyWindow()?.rootViewController?.topMostViewController()
    }
    
    func keyWindow() -> UIWindow? {
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    func openApplicationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL((url)) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Review
    func requestReview() {
        guard let windowScene = UIApplication.shared.keyWindow()?.windowScene else { return }
        SKStoreReviewController.requestReview(in: windowScene)
    }
    
    // MARK: - AppStore
    func openAppStore() {
        let appId = "6744341755"
        let urlString = "https://apps.apple.com/app/id\(appId)"
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
