//
//  BuilderTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit

class ScrollTestBuilder: BaseBuilder {
    func build() -> UIViewController {
        let router = ScrollTestRouter()
        let viewModel = ScrollTestViewModel()
        let viewController = ScrollTestViewController(viewModel: viewModel, router: router)

        return viewController
    }
}
