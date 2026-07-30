//
//  QRScannerViewModel.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import Foundation

// MARK: - Source
protocol QRScannerViewModelDataSource {
    var scannedCode: String? { get }
}

// MARK: - Closure
protocol QRScannerViewModelClosureSource {
    var onCodeScanned: AnyClosure<String>? { get set }
}

// MARK: - Function
protocol QRScannerViewModelFunctionSource {
    func handleScannedValue(_ value: String)
}

// MARK: - Protocol
protocol QRScannerViewModelProtocol: BaseViewModelProtocol,
                                     QRScannerViewModelDataSource,
                                     QRScannerViewModelClosureSource,
                                     QRScannerViewModelFunctionSource { }

// MARK: - ViewModel
final class QRScannerViewModel: BaseViewModel, QRScannerViewModelProtocol {

    // MARK: - Source
    private(set) var scannedCode: String?

    // MARK: - Closure
    var onCodeScanned: AnyClosure<String>?

    // MARK: - Function
    // The camera keeps firing after the first hit; the first value wins and the rest are dropped.
    func handleScannedValue(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard scannedCode == nil, trimmed.isNotEmpty else { return }
        scannedCode = trimmed
        onCodeScanned?(trimmed)
    }
}
