//
//  PermissionSheetBuilder.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

final class PermissionSheetBuilder: BaseBuilder {

    // MARK: - Build
    func build() -> UIViewController {
        let router = PermissionSheetRouter()
        let viewModel = PermissionSheetViewModel()
        viewModel.sheetTitle = SetupLocalizable.permission_title
        viewModel.sheetSubtitle = SetupLocalizable.permission_subtitle
        viewModel.dismissesOnActionTap = false
        viewModel.actions = PermissionSheetActions.make()

        return PermissionSheetViewController(viewModel: viewModel, router: router)
    }
}
