//
//  AppDelegate.swift
//  AppSeed
//
//  Created by tunay alver on 5.01.2025.
//

import UIKit
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import Firebase
import FirebaseCore
import RevenueCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        iqKeyboard()
        LanguageHelper.setAppLanguage()
        IAPHelper.shared.configure()
        firebase()
        return true
    }
    
    private func firebase() {
        let fileName = (Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String == "Debug")
        ? "GoogleService-Info-develop"
        : "GoogleService-Info-release"
        
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
        }
    }
    
    // MARK: - IQKeyboard
    private func iqKeyboard() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.toolbarConfiguration.doneBarButtonConfiguration = .init(title: Localizable.ok)
        IQKeyboardToolbarManager.shared.toolbarConfiguration.tintColor = ColorText.textPrimary.color
    }
}
