//
//  ProfileModels.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// MARK: - Header Model
struct ProfileHeaderModel {
    let userName: String?
    let email: String?
    let avatarURL: String?
}

// MARK: - Cell Type
enum ProfileCellType {
    case header
    case editProfile
    case language
    case theme
    case permissions
    case goPremium
    case feedback
    case rateApp
    case logout
    case deleteAccount

    var title: String? {
        switch self {
        case .editProfile:
            ProfileLocalizable.item_edit_profile
        case .language:
            ProfileLocalizable.item_language
        case .theme:
            ProfileLocalizable.item_theme
        case .permissions:
            ProfileLocalizable.item_permissions
        case .goPremium:
            ProfileLocalizable.item_go_premium
        case .feedback:
            ProfileLocalizable.item_feedback
        case .rateApp:
            ProfileLocalizable.item_rate_app
        case .logout:
            ProfileLocalizable.item_logout
        case .deleteAccount:
            ProfileLocalizable.item_delete_account
        case .header:
            nil
        }
    }

    var subtitle: String? {
        switch self {
        case .goPremium:
            ProfileLocalizable.item_go_premium_subtitle
        default:
            nil
        }
    }

    var icon: String? {
        switch self {
        case .editProfile:
            "person.crop.circle"
        case .language:
            "globe"
        case .theme:
            "paintbrush"
        case .permissions:
            "checkmark.shield"
        case .goPremium:
            "crown"
        case .feedback:
            "message"
        case .rateApp:
            Symbols.star_fill.symbolName
        case .logout:
            "rectangle.portrait.and.arrow.right"
        case .deleteAccount:
            "trash"
        case .header:
            nil
        }
    }

    var isDestructive: Bool {
        if case .deleteAccount = self { return true }
        return false
    }

    var showsChevron: Bool {
        switch self {
        case .header, .logout, .deleteAccount:
            false
        default:
            true
        }
    }
}

// MARK: - Section
enum ProfileSection {
    case header
    case account
    case app
    case premium
    case support
    case session

    var title: String? {
        switch self {
        case .header:
            return nil
        case .account:
            return ProfileLocalizable.section_account
        case .app:
            return ProfileLocalizable.section_app
        case .premium:
            return ProfileLocalizable.section_premium
        case .support:
            return ProfileLocalizable.section_support
        case .session:
            return ProfileLocalizable.section_session
        }
    }

    var cells: [ProfileCellType] {
        switch self {
        case .header:
            [.header]
        case .account:
            [.editProfile]
        case .app:
            [.language, .theme, .permissions]
        case .premium:
            [.goPremium]
        case .support:
            [.feedback, .rateApp]
        case .session:
            [.logout, .deleteAccount]
        }
    }
}
