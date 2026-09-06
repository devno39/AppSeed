//
//  Localizable.swift
//  AppSeed
//
//  Created by tunay alver on 24.11.2024.
//

import Foundation

enum Localizable {
    private static func localized(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Localizable", bundle: LanguageManager.shared.bundle, value: "", comment: "")
    }

    static var ok: String { localized("ok") }
    static var cancel: String { localized("cancel") }
    static var save: String { localized("save") }
    static var delete: String { localized("delete") }
    static var done: String { localized("done") }
    static var edit: String { localized("edit") }
    static var yes: String { localized("yes") }
    static var no: String { localized("no") }
    static var retry: String { localized("retry") }
    static var close: String { localized("close") }
    static var pro: String { localized("pro") }

    // MARK: - What's New
    static var whats_new_title: String { localized("whats_new_title") }
    static var whats_new_button: String { localized("whats_new_button") }
    static var whats_new_1: String { localized("whats_new_1") }
    static var whats_new_2: String { localized("whats_new_2") }
    static var whats_new_3: String { localized("whats_new_3") }

    // MARK: - Database Errors
    static var db_error_title: String { localized("db_error_title") }
    static var db_error_network: String { localized("db_error_network") }
    static var db_error_permission: String { localized("db_error_permission") }
    static var db_error_unknown: String { localized("db_error_unknown") }

    // MARK: - Replicate
    static var replicate_prompt_general: String { localized("replicate_prompt_general") }

    // MARK: - Dalle
    static var dalle_prompt_general: String { localized("dalle_prompt_general") }

    // MARK: - GPT
    static var gpt_prompt_language: String { localized("gpt_prompt_language") }
    static var gpt_prompt_finalReminder: String { localized("gpt_prompt_finalReminder") }
    static var gpt_prompt_jsonFormat: String { localized("gpt_prompt_jsonFormat") }
}
