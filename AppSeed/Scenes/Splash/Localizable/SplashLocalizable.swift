//
//  SplashLocalizable.swift
//  AppSeed
//
//  Created by tunay alver on 24.11.2024.
//

import Foundation

enum SplashLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "SplashLocalizable", bundle: .main, value: "", comment: "")
    }
    
    static var splash_title: String {
        localized("splash_title")
    }
}
