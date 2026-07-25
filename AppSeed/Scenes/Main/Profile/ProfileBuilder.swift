//
//  ProfileBuilder.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class ProfileBuilder: BaseBuilder {

    func build() -> UIViewController {
        let router = ProfileRouter()
        let viewModel = ProfileViewModel(userService: SupabaseUserService())
        let viewController = ProfileViewController(viewModel: viewModel, router: router)
        return viewController
    }
}
