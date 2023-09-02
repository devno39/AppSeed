//
//  UIApplication+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

extension UIApplication {
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
}
