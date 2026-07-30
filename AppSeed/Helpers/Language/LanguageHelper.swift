//
//  LanguageHelper.swift
//  AppSeed
//
//  Created by tunay alver on 13.07.2025.
//

import UIKit

// Case order = language sheet order: alphabetical by endonym (neutral, no perceived ranking)
enum AppLanguage: String, CaseIterable {
    case german = "de"
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case italian = "it"
    case turkish = "tr"

    var speechCode: String {
        switch self {
        case .german: return "de-DE"
        case .english: return "en-US"
        case .spanish: return "es-ES"
        case .french: return "fr-FR"
        case .italian: return "it-IT"
        case .turkish: return "tr-TR"
        }
    }

    var displayTitle: String {
        switch self {
        case .german: return "🇩🇪  Deutsch"
        case .english: return "🇬🇧  English"
        case .spanish: return "🇪🇸  Español"
        case .french: return "🇫🇷  Français"
        case .italian: return "🇮🇹  Italiano"
        case .turkish: return "🇹🇷  Türkçe"
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
        let supported = AppLanguage.allCases.map(\.rawValue)
        return supported.first { deviceLanguage.starts(with: $0) } ?? "en"
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
