//
//  Localizable.swift
//  AppSeed
//
//  Created by tunay alver on 24.11.2024.
//

import Foundation

enum Localizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Localizable", bundle: .main, value: "", comment: "")
    }

    static var ok: String {
        localized("ok")
    }
    static var cancel: String {
        localized("cancel")
    }
    static var save: String {
        localized("save")
    }
    static var delete: String {
        localized("delete")
    }
    static var edit: String {
        localized("edit")
    }
    static var yes: String {
        localized("yes")
    }
    static var no: String {
        localized("no")
    }
    static var retry: String {
        localized("retry")
    }
    static var close: String {
        localized("close")
    }
}
