//
//  QRScannerRouter.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit

// MARK: - Route Protocol
protocol QRScannerRoute {
    func presentQRScanner(onCodeScanned: AnyClosure<String>?)
}

extension QRScannerRoute where Self: BaseRouter {
    func presentQRScanner(onCodeScanned: AnyClosure<String>?) {
        let vc = QRScannerBuilder(onCodeScanned: onCodeScanned).build()
        vc.modalPresentationStyle = .fullScreen
        viewController?.present(vc, animated: true)
    }
}

// MARK: - Router
final class QRScannerRouter: BaseRouter { }
