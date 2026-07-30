//
//  QRScannerBuilder.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

final class QRScannerBuilder: BaseBuilder {

    // MARK: - Properties
    private let onCodeScanned: AnyClosure<String>?

    // MARK: - Init
    init(onCodeScanned: AnyClosure<String>?) {
        self.onCodeScanned = onCodeScanned
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = QRScannerRouter()
        let viewModel = QRScannerViewModel()
        viewModel.onCodeScanned = onCodeScanned

        return QRScannerViewController(viewModel: viewModel, router: router)
    }
}
