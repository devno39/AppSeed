//
//  LanguageHelper.swift
//  AppSeed
//
//  Created by tunay alver on 13.07.2025.
//

import UIKit

enum AppLanguage: String {
    case turkish = "tr"
    case english = "en"
    
    var speechCode: String {
        switch self {
        case .turkish: return "tr-TR"
        case .english: return "en-US"
        }
    }
    
    static var current: AppLanguage {
        AppLanguage(rawValue: LanguageHelper.selectedLanguage) ?? .english
    }
}

final class LanguageHelper {
    
    @UserDefault(.selectedLanguage, defaultValue: defaultLanguage)
    static var selectedLanguage: String
    
    private static var defaultLanguage: String {
        let deviceLanguage = Locale.preferredLanguages.first ?? "en"
        return deviceLanguage.starts(with: "tr") ? "tr" : "en"
    }
    
    static func setAppLanguage() {
        let storedLanguage = selectedLanguage
        UserDefaults.standard.set([storedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    static func changeLanguage(to language: String) {
        guard language != selectedLanguage else { return }
        
        selectedLanguage = language
        setAppLanguage()
        restartApp()
    }
    
    private static func restartApp() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = scene.delegate as? SceneDelegate
        else { return }
        
        let newWindow = UIWindow(windowScene: scene)
        let splashViewController = SplashBuilder().build()
        
        newWindow.rootViewController = splashViewController
        sceneDelegate.window = newWindow
        newWindow.makeKeyAndVisible()
        
        UIView.transition(with: newWindow, duration: 0.5, options: .transitionCrossDissolve, animations: {}, completion: nil)
    }
}
