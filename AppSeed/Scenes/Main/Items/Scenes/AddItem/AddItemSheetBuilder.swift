//
//  AddItemSheetBuilder.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import UIKit

final class AddItemSheetBuilder: BaseBuilder {

    // MARK: - Properties
    private let onSubmit: AnyClosure<AddItemModel>?

    // MARK: - Init
    init(onSubmit: AnyClosure<AddItemModel>?) {
        self.onSubmit = onSubmit
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = AddItemSheetRouter()
        let viewModel = AddItemSheetViewModel()
        viewModel.sheetTitle = ItemsLocalizable.add_title
        viewModel.saveTitle = ItemsLocalizable.add_save
        viewModel.onSubmit = onSubmit

        return AddItemSheetViewController(viewModel: viewModel, router: router)
    }
}
