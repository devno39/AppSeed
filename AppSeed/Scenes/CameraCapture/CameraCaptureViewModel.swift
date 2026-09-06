//
//  CameraCaptureViewModel.swift
//  AppSeed
//
//  Created by Claude on 14.08.2026.
//

import UIKit
import AVFoundation

// MARK: - Source
protocol CameraCaptureViewModelDataSource {
    var isCameraAvailable: Bool { get }
    var isCameraDenied: Bool { get }
}

// MARK: - Closure
protocol CameraCaptureViewModelClosureSource {
    var onCaptured: AnyClosure<UIImage>? { get set }
}

// MARK: - Function
protocol CameraCaptureViewModelFunctionSource {
    func requestCameraAccess(completion: @escaping BoolClosure)
}

// MARK: - Protocol
protocol CameraCaptureViewModelProtocol: BaseViewModelProtocol,
                                         CameraCaptureViewModelDataSource,
                                         CameraCaptureViewModelClosureSource,
                                         CameraCaptureViewModelFunctionSource {}

// MARK: - ViewModel
final class CameraCaptureViewModel: BaseViewModel, CameraCaptureViewModelProtocol {

    // MARK: - Source
    var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var isCameraDenied: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .denied
    }

    // MARK: - Closure
    var onCaptured: AnyClosure<UIImage>?

    // MARK: - Function
    func requestCameraAccess(completion: @escaping BoolClosure) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    }
}
