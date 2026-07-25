//
//  BottomSheetBuilder.swift
//  AppSeed
//
//  Created by Codex on 22.02.2026.
//

import UIKit

final class BottomSheetBuilder: BaseBuilder {

    // MARK: - Properties
    private let sheetTitle: String?
    private let sheetSubtitle: String?
    private let actions: [BottomSheetAction]
    private let button: BottomSheetButton?
    private let customView: UIView?

    // MARK: - Init
    init(title: String? = nil, subtitle: String? = nil, actions: [BottomSheetAction] = [], button: BottomSheetButton? = nil, customView: UIView? = nil) {
        self.sheetTitle = title
        self.sheetSubtitle = subtitle
        self.actions = actions
        self.button = button
        self.customView = customView
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = BottomSheetRouter()
        let viewModel = BottomSheetViewModel()
        viewModel.sheetTitle = sheetTitle
        viewModel.sheetSubtitle = sheetSubtitle
        viewModel.actions = actions
        viewModel.button = button
        viewModel.customView = customView

        let viewController = BottomSheetViewController(viewModel: viewModel, router: router)
        return viewController
    }
}
