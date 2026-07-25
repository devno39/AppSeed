//
//  FeedbackSheetRouter.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol FeedbackSheetRoute {
    func presentFeedbackSheet()
}

extension FeedbackSheetRoute where Self: BaseRouter {
    func presentFeedbackSheet() {
        let vc = FeedbackSheetBuilder().build()
        vc.modalPresentationStyle = .overFullScreen
        viewController?.present(vc, animated: false)
    }
}

// MARK: - Router
final class FeedbackSheetRouter: BaseRouter { }
