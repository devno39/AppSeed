//
//  PermissionSheetViewController.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

final class PermissionSheetViewController: BottomSheetViewController<PermissionSheetViewModel, PermissionSheetRouter> {

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePermissionsChanged),
            name: .permissionsDidChange,
            object: nil
        )
        // Refresh after the Settings round-trip — iOS posts nothing when the user returns.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Permission Observers
    @objc private func handlePermissionsChanged() {
        PermissionManager.shared.refreshNotificationStatus { [weak self] in
            self?.reloadActions(PermissionSheetActions.make())
            guard PermissionManager.shared.allGranted else { return }
            self?.dismiss(animated: true)
        }
    }

    @objc private func handleAppDidBecomeActive() {
        PermissionManager.shared.notifyChange()
    }
}
