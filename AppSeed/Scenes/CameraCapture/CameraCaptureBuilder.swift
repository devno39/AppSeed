//
//  CameraCaptureBuilder.swift
//  AppSeed
//
//  Created by Claude on 14.08.2026.
//

import UIKit

final class CameraCaptureBuilder: BaseBuilder {

    // MARK: - Properties
    private let onCaptured: AnyClosure<UIImage>?

    // MARK: - Init
    init(onCaptured: AnyClosure<UIImage>?) {
        self.onCaptured = onCaptured
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = CameraCaptureRouter()
        let viewModel = CameraCaptureViewModel()
        viewModel.onCaptured = onCaptured

        return CameraCaptureViewController(viewModel: viewModel, router: router)
    }
}
