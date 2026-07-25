//
//  FormBottomSheetRouter.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import UIKit

// MARK: - Route Protocol
protocol FormBottomSheetRoute {
    func presentFormSheet(_ sheet: UIViewController)
}

extension FormBottomSheetRoute where Self: BaseRouter {
    func presentFormSheet(_ sheet: UIViewController) {
        sheet.modalPresentationStyle = .overFullScreen
        viewController?.present(sheet, animated: false)
    }
}

// MARK: - Router
class FormBottomSheetRouter: BaseRouter, FormBottomSheetRoute {}
