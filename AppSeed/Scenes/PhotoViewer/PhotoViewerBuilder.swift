//
//  PhotoViewerBuilder.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

final class PhotoViewerBuilder: BaseBuilder {

    // MARK: - Properties
    private let imageURLs: [String]
    private let startIndex: Int
    private let info: PhotoViewerInfo?
    private let actions: [BottomSheetAction]
    private let sourceFrame: CGRect?
    private let sourceImage: UIImage?

    // MARK: - Init
    init(
        imageURLs: [String],
        startIndex: Int = 0,
        info: PhotoViewerInfo? = nil,
        actions: [BottomSheetAction] = [],
        sourceFrame: CGRect? = nil,
        sourceImage: UIImage? = nil
    ) {
        self.imageURLs = imageURLs
        self.startIndex = startIndex
        self.info = info
        self.actions = actions
        self.sourceFrame = sourceFrame
        self.sourceImage = sourceImage
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = PhotoViewerRouter()
        let viewModel = PhotoViewerViewModel(
            imageURLs: imageURLs,
            startIndex: startIndex,
            info: info,
            actions: actions
        )
        let viewController = PhotoViewerViewController(viewModel: viewModel, router: router)

        let nav = BaseNavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = .overFullScreen

        if let sourceFrame, sourceFrame != .zero, let sourceImage {
            let transitionDelegate = ZoomTransitionDelegate.photoViewer(
                sourceFrame: sourceFrame,
                sourceImage: sourceImage
            )
            viewController.transitionDelegate = transitionDelegate
            nav.transitioningDelegate = transitionDelegate
        } else {
            nav.modalTransitionStyle = .crossDissolve
        }
        return nav
    }
}
