//
//  PermissionSheetModels.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import Foundation

extension PermissionType {

    var icon: String {
        switch self {
        case .location:
            "location"
        case .notification:
            "bell"
        case .photos:
            "photo.on.rectangle"
        }
    }

    var title: String {
        switch self {
        case .location:
            SetupLocalizable.permission_location_title
        case .notification:
            SetupLocalizable.permission_notification_title
        case .photos:
            SetupLocalizable.permission_photos_title
        }
    }

    var subtitle: String {
        switch self {
        case .location:
            SetupLocalizable.permission_location_subtitle
        case .notification:
            SetupLocalizable.permission_notification_subtitle
        case .photos:
            SetupLocalizable.permission_photos_subtitle
        }
    }
}

// MARK: - Actions
// Shared by the builder and the controller's refresh so both render the same rows.
enum PermissionSheetActions {
    static func make() -> [BottomSheetAction] {
        PermissionType.allCases.map { type in
            let granted = PermissionManager.shared.isGranted(type)
            return BottomSheetAction(
                title: type.title,
                subtitle: type.subtitle,
                icon: type.icon,
                style: .selectable,
                isEnabled: !granted,
                isSelected: granted,
                handler: {
                    PermissionManager.shared.requestOrOpenSettings(type)
                }
            )
        }
    }
}
