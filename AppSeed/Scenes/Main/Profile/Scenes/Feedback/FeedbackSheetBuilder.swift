//
//  FeedbackSheetBuilder.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class FeedbackSheetBuilder: BaseBuilder {

    // MARK: - Build
    func build() -> UIViewController {
        let router = FeedbackSheetRouter()
        let viewModel = FeedbackSheetViewModel()
        viewModel.sheetTitle = ProfileLocalizable.feedback_sheet_title
        viewModel.sheetSubtitle = ProfileLocalizable.feedback_sheet_subtitle
        viewModel.saveTitle = ProfileLocalizable.feedback_send

        let viewController = FeedbackSheetViewController(viewModel: viewModel, router: router)
        return viewController
    }
}
