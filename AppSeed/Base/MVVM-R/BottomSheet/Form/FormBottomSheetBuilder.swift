//
//  FormBottomSheetBuilder.swift
//  AppSeed
//
//  Created by Claude on 13.03.2026.
//

import UIKit

final class FormBottomSheetBuilder: BaseBuilder {

    // MARK: - Properties
    private let sheetTitle: String?
    private let sheetSubtitle: String?
    private let saveTitle: String
    private let onSave: EmptyClosure?

    // MARK: - Init
    init(
        title: String? = nil,
        subtitle: String? = nil,
        saveTitle: String = "Save",
        onSave: EmptyClosure? = nil
    ) {
        self.sheetTitle = title
        self.sheetSubtitle = subtitle
        self.saveTitle = saveTitle
        self.onSave = onSave
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = FormBottomSheetRouter()
        let viewModel = FormBottomSheetViewModel()
        viewModel.sheetTitle = sheetTitle
        viewModel.sheetSubtitle = sheetSubtitle
        viewModel.saveTitle = saveTitle
        viewModel.onSave = onSave

        let viewController = FormBottomSheetViewController(viewModel: viewModel, router: router)
        return viewController
    }
}
