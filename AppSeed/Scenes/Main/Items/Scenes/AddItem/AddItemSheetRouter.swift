//
//  AddItemSheetRouter.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol AddItemSheetRoute {
    func presentAddItemSheet(onSubmit: AnyClosure<AddItemModel>?)
}

extension AddItemSheetRoute where Self: BaseRouter {
    func presentAddItemSheet(onSubmit: AnyClosure<AddItemModel>?) {
        let vc = AddItemSheetBuilder(onSubmit: onSubmit).build()
        vc.modalPresentationStyle = .overFullScreen
        viewController?.present(vc, animated: false)
    }
}

// MARK: - Router
final class AddItemSheetRouter: FormBottomSheetRouter { }
