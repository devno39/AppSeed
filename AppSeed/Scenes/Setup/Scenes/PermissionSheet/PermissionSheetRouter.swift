//
//  PermissionSheetRouter.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol PermissionSheetRoute {
    func presentPermissionSheet()
}

extension PermissionSheetRoute where Self: BaseRouter {
    func presentPermissionSheet() {
        let vc = PermissionSheetBuilder().build()
        vc.modalPresentationStyle = .overFullScreen
        viewController?.present(vc, animated: false)
    }
}

// MARK: - Router
final class PermissionSheetRouter: BottomSheetRouter { }
