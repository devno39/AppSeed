//
//  BuilderTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit

class TutorialBuilder: BaseBuilder {
    func build() -> UIViewController {
        let router = TutorialRouter()
        let viewModel = TutorialViewModel()
        let viewController = TutorialViewController(viewModel: viewModel, router: router)

        return viewController
    }
}
