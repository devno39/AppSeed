//
//  PermissionSheetBuilder.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

final class PermissionSheetBuilder: BaseBuilder {

    // MARK: - Properties
    private let onDismiss: EmptyClosure?

    // MARK: - Init
    init(onDismiss: EmptyClosure? = nil) {
        self.onDismiss = onDismiss
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = PermissionSheetRouter()
        let viewModel = PermissionSheetViewModel()
        viewModel.sheetTitle = SetupLocalizable.permission_title
        viewModel.sheetSubtitle = SetupLocalizable.permission_subtitle
        viewModel.dismissesOnActionTap = false
        // Swipe still closes it; only the accidental backdrop tap is off.
        viewModel.dismissesOnBackdropTap = false
        viewModel.actions = PermissionSheetActions.make()
        viewModel.onDismiss = onDismiss

        return PermissionSheetViewController(viewModel: viewModel, router: router)
    }
}
