//
//  BuilderTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit

class ___VARIABLE_name___Builder: BaseBuilder {
    func build() -> UIViewController {
        let router = ___VARIABLE_name___Router()
        let viewModel = ___VARIABLE_name___ViewModel()
        let viewController = ___VARIABLE_name___ViewController(viewModel: viewModel, router: router)

        return viewController
    }
}
