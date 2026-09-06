//
//  CameraCaptureRouter.swift
//  AppSeed
//
//  Created by Claude on 14.08.2026.
//

import UIKit

// MARK: - Route Protocol
protocol CameraCaptureRoute {
    func presentCameraCapture(onCaptured: AnyClosure<UIImage>?)
}

extension CameraCaptureRoute where Self: BaseRouter {
    func presentCameraCapture(onCaptured: AnyClosure<UIImage>?) {
        let vc = CameraCaptureBuilder(onCaptured: onCaptured).build()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        viewController?.present(vc, animated: false)
    }
}

// MARK: - Router
final class CameraCaptureRouter: BaseRouter { }
