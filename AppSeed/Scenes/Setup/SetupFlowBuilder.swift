//
//  SetupFlowBuilder.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class SetupFlowBuilder: BaseBuilder {

    // MARK: - Properties
    private let onComplete: EmptyClosure?

    // MARK: - Init
    init(onComplete: EmptyClosure? = nil) {
        self.onComplete = onComplete
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = SetupFlowRouter()
        let viewModel = SetupFlowViewModel(userService: SupabaseUserService())
        viewModel.sheetTitle = SetupLocalizable.title
        viewModel.sheetSubtitle = SetupLocalizable.subtitle
        viewModel.saveTitle = SetupLocalizable.save
        viewModel.onComplete = onComplete

        let user = UserSessionManager.shared.currentUser
        if let name = user?.displayName, !name.isEmpty {
            viewModel.displayName = name
        }
        viewModel.birthDate = user?.birthDate

        let viewController = SetupFlowViewController(viewModel: viewModel, router: router)
        return viewController
    }
}
