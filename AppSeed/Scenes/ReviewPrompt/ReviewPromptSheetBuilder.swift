//
//  ReviewPromptSheetBuilder.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

final class ReviewPromptSheetBuilder: BaseBuilder {

    // MARK: - Properties
    private let onYes: EmptyClosure?
    private let onLater: EmptyClosure?
    private let onDismiss: EmptyClosure?

    // MARK: - Init
    init(onYes: EmptyClosure?, onLater: EmptyClosure?, onDismiss: EmptyClosure? = nil) {
        self.onYes = onYes
        self.onLater = onLater
        self.onDismiss = onDismiss
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = ReviewPromptSheetRouter()
        let viewModel = ReviewPromptSheetViewModel()
        viewModel.sheetTitle = ProfileLocalizable.review_prompt_title
        viewModel.sheetSubtitle = ProfileLocalizable.review_prompt_subtitle
        viewModel.actions = [
            BottomSheetAction(
                title: ProfileLocalizable.review_prompt_yes,
                icon: Symbols.heart_fill.symbolName,
                handler: { [onYes] in onYes?() }
            ),
            BottomSheetAction(
                title: ProfileLocalizable.review_prompt_later,
                icon: Symbols.bubble_left_fill.symbolName,
                handler: { [onLater] in onLater?() }
            )
        ]
        viewModel.onDismiss = onDismiss

        return ReviewPromptSheetViewController(viewModel: viewModel, router: router)
    }
}
