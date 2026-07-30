//
//  ProfileRouter.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol ProfileRoute {
    func pushProfile()
}

extension ProfileRoute where Self: BaseRouter {
    func pushProfile() {
        let vc = ProfileBuilder().build()
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Router
final class ProfileRouter: BaseRouter, LoginRoute, BottomSheetRoute, FormBottomSheetRoute, PaywallRoute, FeedbackSheetRoute, PermissionSheetRoute { }
