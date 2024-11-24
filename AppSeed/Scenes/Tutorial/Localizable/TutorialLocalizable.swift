//
//  TutorialLocalizable.swift
//  AppSeed
//
//  Created by tunay alver on 24.11.2024.
//

import Foundation

enum TutorialLocalizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "TutorialLocalizable", bundle: .main, value: "", comment: "")
    }
    
    static var tutorial_title_1: String {
        localized("tutorial_title_1")
    }
    static var tutorial_title_2: String {
        localized("tutorial_title_2")
    }
    static var tutorial_title_3: String {
        localized("tutorial_title_3")
    }
    
    static var tutorial_subtitle_1: String {
        localized("tutorial_subtitle_1")
    }
    static var tutorial_subtitle_2: String {
        localized("tutorial_subtitle_2")
    }
    static var tutorial_subtitle_3: String {
        localized("tutorial_subtitle_3")
    }
    
    static var actionButton_title: String {
        localized("actionButton_title")
    }
    static var actionButton_title_end: String {
        localized("actionButton_title_end")
    }
}
