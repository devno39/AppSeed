//
//  BottomSheetRouter.swift
//  AppSeed
//
//  Created by Codex on 22.02.2026.
//

import UIKit

// MARK: - Route Protocol
protocol BottomSheetRoute {
    func presentBottomSheet(title: String?, subtitle: String?, actions: [BottomSheetAction], button: BottomSheetButton?, customView: UIView?)
}

extension BottomSheetRoute where Self: BaseRouter {
    func presentBottomSheet(title: String? = nil, subtitle: String? = nil, actions: [BottomSheetAction] = [], button: BottomSheetButton? = nil, customView: UIView? = nil) {
        let vc = BottomSheetBuilder(title: title, subtitle: subtitle, actions: actions, button: button, customView: customView).build()
        vc.modalPresentationStyle = .overFullScreen
        viewController?.present(vc, animated: false)
    }
}

// MARK: - Router
class BottomSheetRouter: BaseRouter, BottomSheetRoute {}
