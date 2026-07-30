//
//  QRScannerViewController.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit
import AVFoundation
import SnapKit

final class QRScannerViewController: BaseViewController<QRScannerViewModel, QRScannerRouter> {

    // MARK: - UI
    private lazy var blurView: UIVisualEffectView = {
        UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    }()

    private lazy var scanFrameView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = Palette.palette1.color.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = cornerRadius
        return view
    }()

    private lazy var closeButton: FloatingActionButton = {
        let button = FloatingActionButton()
        button.setIcon(name: Symbols.xmark.symbolName, color: ColorText.textPrimary.color)
        button.onTap = { [weak self] in
            self?.dismiss(animated: true)
        }
        return button
    }()

    // MARK: - Constants
    private let scanSize: CGFloat = 250
    private let cornerRadius: CGFloat = 24

    // MARK: - Properties
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ensureCameraAccess { [weak self] granted in
            guard let self else { return }
            guard granted else {
                self.presentPermissionAlert()
                return
            }
            // setupCamera() bailed out in prepare() while auth was still undetermined.
            if self.captureSession == nil {
                self.setupCamera()
            }
            self.startScanning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        applyCutout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        draw()
        setupCamera()
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()

        let externalHandler = viewModel?.onCodeScanned
        viewModel?.onCodeScanned = { [weak self] code in
            guard let self else { return }
            self.captureSession?.stopRunning()
            self.dismiss(animated: true) {
                externalHandler?(code)
            }
        }
    }

    // MARK: - Camera Permission
    private func ensureCameraAccess(completion: @escaping BoolClosure) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    private func presentPermissionAlert() {
        AlertHelper.showAlert(
            title: QRScannerLocalizable.camera_permission_title,
            message: QRScannerLocalizable.camera_permission_message,
            primaryTitle: QRScannerLocalizable.camera_permission_open_settings,
            secondaryTitle: Localizable.cancel,
            primaryAction: {
                UIApplication.shared.openApplicationSettings()
            },
            secondaryAction: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
    }

    // MARK: - Camera
    private func setupCamera() {
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]
        }

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.insertSublayer(preview, at: 0)

        captureSession = session
        previewLayer = preview
    }

    private func startScanning() {
        guard let session = captureSession, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    // MARK: - Private
    private func applyCutout() {
        let fullPath = UIBezierPath(rect: view.bounds)
        fullPath.append(UIBezierPath(roundedRect: scanFrameView.frame, cornerRadius: cornerRadius))
        fullPath.usesEvenOddFillRule = true

        let maskLayer = CAShapeLayer()
        maskLayer.path = fullPath.cgPath
        maskLayer.fillRule = .evenOdd
        blurView.layer.mask = maskLayer
    }

    // MARK: - Localization
    override func configureLocalization() {
        super.configureLocalization()
        title = QRScannerLocalizable.title
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadata.type == .qr,
              let value = metadata.stringValue else { return }
        viewModel?.handleScannedValue(value)
    }
}

// MARK: - Draw
extension QRScannerViewController {
    private func draw() {
        view.addSubview(blurView)
        view.addSubview(scanFrameView)
        view.addSubview(closeButton)

        blurView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        scanFrameView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(scanSize)
        }

        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}
