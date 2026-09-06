//
//  PermissionSheetRouter.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol PermissionSheetRoute {
    func presentPermissionSheet(onDismiss: EmptyClosure?, onPresented: EmptyClosure?)
}

extension PermissionSheetRoute where Self: BaseRouter {
    // onPresented, not "before present": counted before it, a dropped presentation spends a turn unseen.
    func presentPermissionSheet(onDismiss: EmptyClosure? = nil, onPresented: EmptyClosure? = nil) {
        let vc = PermissionSheetBuilder(onDismiss: onDismiss).build()
        vc.modalPresentationStyle = .overFullScreen
        viewController?.present(vc, animated: false, completion: onPresented)
    }
}

// MARK: - Router
final class PermissionSheetRouter: BottomSheetRouter { }
