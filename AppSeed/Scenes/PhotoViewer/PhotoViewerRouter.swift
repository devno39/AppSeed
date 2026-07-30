//
//  PhotoViewerRouter.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol PhotoViewerRoute {
    func presentPhotoViewer(
        imageURLs: [String],
        startIndex: Int,
        info: PhotoViewerInfo?,
        actions: [BottomSheetAction],
        sourceFrame: CGRect?,
        sourceImage: UIImage?
    )
}

extension PhotoViewerRoute where Self: BaseRouter {
    func presentPhotoViewer(
        imageURLs: [String],
        startIndex: Int = 0,
        info: PhotoViewerInfo? = nil,
        actions: [BottomSheetAction] = [],
        sourceFrame: CGRect? = nil,
        sourceImage: UIImage? = nil
    ) {
        let vc = PhotoViewerBuilder(
            imageURLs: imageURLs,
            startIndex: startIndex,
            info: info,
            actions: actions,
            sourceFrame: sourceFrame,
            sourceImage: sourceImage
        ).build()
        viewController?.present(vc, animated: true)
    }
}

// MARK: - Router
final class PhotoViewerRouter: BaseRouter, BottomSheetRoute { }
