//
//  ___VARIABLE_name___Builder.swift
//  AppSeed
//

import UIKit

final class ___VARIABLE_name___Builder: BaseBuilder {

    func build() -> UIViewController {
        let router = ___VARIABLE_name___Router()
        let viewModel = ___VARIABLE_name___ViewModel()
        viewModel.sheetTitle = "Title"
        viewModel.saveTitle = Localizable.done

        let viewController = ___VARIABLE_name___ViewController(viewModel: viewModel, router: router)
        return viewController
    }
}
