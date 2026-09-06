//
//  ReviewPromptSheetRouter.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol ReviewPromptSheetRoute {
    func presentReviewPromptSheet(onYes: EmptyClosure?, onLater: EmptyClosure?, onDismiss: EmptyClosure?)
}

extension ReviewPromptSheetRoute where Self: BaseRouter {
    func presentReviewPromptSheet(onYes: EmptyClosure?, onLater: EmptyClosure?, onDismiss: EmptyClosure? = nil) {
        let vc = ReviewPromptSheetBuilder(onYes: onYes, onLater: onLater, onDismiss: onDismiss).build()
        vc.modalPresentationStyle = .overFullScreen
        viewController?.present(vc, animated: false)
    }
}

// MARK: - Router
final class ReviewPromptSheetRouter: BottomSheetRouter { }
