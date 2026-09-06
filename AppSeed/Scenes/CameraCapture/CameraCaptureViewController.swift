//
//  CameraCaptureViewController.swift
//  AppSeed
//
//  Created by Claude on 14.08.2026.
//

import UIKit
import SnapKit

final class CameraCaptureViewController: BaseViewController<CameraCaptureViewModel, CameraCaptureRouter> {

    // MARK: - UI
    private lazy var previewImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = cardCornerRadius
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        return view
    }()

    private lazy var useButton: BaseButton = {
        let button = BaseButton(style: .primary)
        button.setTitle(CameraCaptureLocalizable.preview_use, for: .normal)
        button.addTarget(self, action: #selector(useTapped), for: .touchUpInside)
        return button
    }()

    private lazy var retakeButton: FloatingActionButton = {
        let view = FloatingActionButton()
        view.setIcon(name: Symbols.camera.symbolName, color: ColorText.textPrimary.color)
        view.onTap = { [weak self] in self?.retakeTapped() }
        return view
    }()

    private lazy var closeButton: FloatingActionButton = {
        let view = FloatingActionButton()
        view.setIcon(name: Symbols.xmark.symbolName, color: ColorText.textPrimary.color)
        view.onTap = { [weak self] in self?.close() }
        return view
    }()

    // MARK: - Constants
    private let cardCornerRadius: CGFloat = 20
    private let shutterSize: CGFloat = 68
    private let sideButtonSize: CGFloat = 44

    // MARK: - Properties
    private var hasStarted = false
    private weak var activePicker: UIImagePickerController?
    private var isCapturing = false

    // MARK: - Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasStarted else { return }
        hasStarted = true
        startCapture()
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        view.backgroundColor = .clear
        draw()
        setPreviewVisible(false)
    }

    // MARK: - Capture
    private func startCapture() {
        #if targetEnvironment(simulator)
        presentPicker()
        #else
        guard viewModel?.isCameraAvailable == true else {
            showCameraUnavailable()
            return
        }

        if viewModel?.isCameraDenied == true {
            showCameraDenied()
            return
        }

        viewModel?.requestCameraAccess { [weak self] granted in
            guard let self else { return }
            if granted {
                self.presentPicker()
            } else {
                self.showCameraDenied()
            }
        }
        #endif
    }

    private func presentPicker(useLibrary: Bool = false) {
        let picker = UIImagePickerController()
        #if targetEnvironment(simulator)
        picker.sourceType = .photoLibrary
        #else
        if useLibrary {
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = .camera
            picker.cameraDevice = .front
            picker.showsCameraControls = false
            centerCameraPreview(picker)
            picker.cameraOverlayView = cameraControls(in: picker.view.bounds, picker: picker)
        }
        #endif
        // Library picks arrive in any aspect; camera shots are already framed square.
        picker.allowsEditing = useLibrary
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        picker.modalTransitionStyle = .crossDissolve
        present(picker, animated: true)
    }

    @objc private func shutterPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.12) {
            sender.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
            sender.alpha = 0.7
        }
    }

    @objc private func shutterReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.18, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4) {
            sender.transform = .identity
            sender.alpha = 1
        }
    }

    // takePicture is async — the held pressed state turns an unexplained wait into visible progress.
    @objc private func shutterTapped(_ sender: UIButton) {
        guard !isCapturing else { return }
        isCapturing = true
        sender.isEnabled = false
        activePicker?.takePicture()
    }

    @objc private func flipTapped() {
        guard let picker = activePicker else { return }
        picker.cameraDevice = picker.cameraDevice == .front ? .rear : .front
    }

    @objc private func libraryTapped() {
        presentedViewController?.dismiss(animated: false) { [weak self] in
            self?.presentPicker(useLibrary: true)
        }
    }

    private func cameraCancelTapped() {
        activePicker?.dismiss(animated: true) { [weak self] in
            guard let self, self.previewImageView.image == nil else { return }
            self.close()
        }
    }

    // MARK: - Preview
    // alpha alone still lets a frame render before layout settles — isHidden is what guarantees it.
    private func setPreviewVisible(_ visible: Bool) {
        [previewImageView, useButton, retakeButton, closeButton].forEach {
            $0.alpha = visible ? 1 : 0
            $0.isHidden = !visible
        }
    }

    private func showPreview(with image: UIImage, isCropped: Bool) {
        previewImageView.image = image
        previewImageView.contentMode = isCropped ? .scaleAspectFill : .scaleAspectFit
        view.backgroundColor = ColorBackground.backgroundPrimary.color

        [previewImageView, useButton, retakeButton, closeButton].forEach { $0.isHidden = false }
        previewImageView.alpha = 1
        useButton.alpha = 0
        retakeButton.alpha = 0
        closeButton.alpha = 0
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.28, delay: 0.05) {
            self.useButton.alpha = 1
            self.retakeButton.alpha = 1
            self.closeButton.alpha = 1
        }
    }

    // MARK: - Actions
    @objc private func useTapped() {
        guard let image = previewImageView.image else { return }
        viewModel?.onCaptured?(image)
        close()
    }

    private func retakeTapped() {
        isCapturing = false
        setPreviewVisible(false)
        previewImageView.image = nil
        view.backgroundColor = .clear
        presentPicker()
    }

    private func close() {
        dismiss(animated: true)
    }

    // MARK: - Alerts
    private func showCameraDenied() {
        AlertHelper.showAlert(
            title: CameraCaptureLocalizable.permission_title,
            message: CameraCaptureLocalizable.permission_message,
            primaryTitle: CameraCaptureLocalizable.permission_settings,
            secondaryTitle: Localizable.cancel,
            primaryAction: { [weak self] in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
                self?.close()
            },
            secondaryAction: { [weak self] in self?.close() }
        )
    }

    private func showCameraUnavailable() {
        AlertHelper.showAlert(
            title: CameraCaptureLocalizable.unavailable_title,
            message: CameraCaptureLocalizable.unavailable_message,
            primaryAction: { [weak self] in self?.close() }
        )
    }

    // MARK: - Private
    // The preview is top-aligned by default — centering it puts the square over the frame's middle.
    private func centerCameraPreview(_ picker: UIImagePickerController) {
        let screen = UIScreen.main.bounds
        let previewHeight = screen.width * 4 / 3
        let offset = (screen.height - previewHeight) / 2
        picker.cameraViewTransform = CGAffineTransform(translationX: 0, y: offset)
    }

    // Built against the picker's bounds, so it can't be a lazy var. Apple's own bar has no library affordance.
    private func cameraControls(in bounds: CGRect, picker: UIImagePickerController) -> UIView {
        let overlay = PassthroughView(frame: bounds)
        activePicker = picker

        let safeTop = view.safeAreaInsets.top
        let safeBottom = view.safeAreaInsets.bottom
        let inset: CGFloat = 20
        let side = bounds.width - inset * 2
        let window = CGRect(
            x: inset,
            y: safeTop + (bounds.height - safeTop - safeBottom - side) / 2,
            width: side,
            height: side
        )

        // Must match the preview screen's image rect — that is what makes the shot freeze in place.
        let dim = UIView(frame: bounds)
        dim.backgroundColor = .black
        let path = UIBezierPath(rect: bounds)
        path.append(UIBezierPath(roundedRect: window, cornerRadius: cardCornerRadius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillRule = .evenOdd
        dim.layer.mask = mask
        overlay.addSubview(dim)

        let bar = UIView()
        overlay.addSubview(bar)
        bar.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(overlay.snp.top).offset(window.maxY)
        }

        let shutter = UIButton(type: .custom)
        shutter.backgroundColor = .white
        shutter.layer.cornerRadius = shutterSize / 2
        shutter.layer.borderWidth = 4
        shutter.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        shutter.addTarget(self, action: #selector(shutterPressed), for: [.touchDown, .touchDragEnter])
        shutter.addTarget(self, action: #selector(shutterReleased), for: [.touchUpOutside, .touchDragExit, .touchCancel])
        shutter.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        bar.addSubview(shutter)
        shutter.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(shutterSize)
        }

        let library = glassButton(icon: Symbols.photo_on_rectangle.symbolName, action: #selector(libraryTapped))
        bar.addSubview(library)
        library.snp.makeConstraints {
            $0.centerY.equalTo(shutter)
            $0.left.equalToSuperview().offset(32)
            $0.size.equalTo(sideButtonSize)
        }

        let flip = glassButton(icon: Symbols.arrow_triangle_2_circlepath_camera.symbolName, action: #selector(flipTapped))
        bar.addSubview(flip)
        flip.snp.makeConstraints {
            $0.centerY.equalTo(shutter)
            $0.right.equalToSuperview().inset(32)
            $0.size.equalTo(sideButtonSize)
        }

        let cancel = FloatingActionButton()
        cancel.setIcon(name: Symbols.xmark.symbolName, color: .white)
        cancel.onTap = { [weak self] in self?.cameraCancelTapped() }
        overlay.addSubview(cancel)
        cancel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(safeTop + 8)
            $0.right.equalToSuperview().inset(20)
            $0.size.equalTo(FloatingActionButton.size)
        }

        overlay.passthroughExceptions = [bar, cancel]
        return overlay
    }

    private func glassButton(icon: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        button.layer.cornerRadius = sideButtonSize / 2
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func squareCropped(_ image: UIImage) -> UIImage {
        let side = min(image.size.width, image.size.height)
        let origin = CGPoint(x: (image.size.width - side) / 2, y: (image.size.height - side) / 2)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        return renderer.image { _ in
            image.draw(at: CGPoint(x: -origin.x, y: -origin.y))
        }
    }

    // MARK: - Localization
    override func configureLocalization() {
        useButton.setTitle(CameraCaptureLocalizable.preview_use, for: .normal)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CameraCaptureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let edited = info[.editedImage] as? UIImage
        let original = info[.originalImage] as? UIImage
        let fromCamera = picker.sourceType == .camera
        let image = edited ?? (fromCamera ? original.map(squareCropped) : original)
        let isSquare = edited != nil || fromCamera
        isCapturing = false
        guard let image else {
            picker.dismiss(animated: true) { [weak self] in self?.close() }
            return
        }
        // No cross-fade: the shot lands in the rect the camera window just occupied.
        showPreview(with: image, isCropped: isSquare)
        picker.dismiss(animated: false)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCapturing = false
        let returnsToCamera = picker.sourceType == .photoLibrary && viewModel?.isCameraAvailable == true

        picker.dismiss(animated: !returnsToCamera) { [weak self] in
            guard let self else { return }
            if returnsToCamera {
                self.presentPicker()
            } else if self.previewImageView.image == nil {
                self.close()
            }
        }
    }
}

// MARK: - Draw
extension CameraCaptureViewController {
    private func draw() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            $0.right.equalToSuperview().inset(20)
            $0.size.equalTo(FloatingActionButton.size)
        }

        view.addSubview(retakeButton)
        retakeButton.snp.makeConstraints {
            $0.centerY.equalTo(closeButton)
            $0.right.equalTo(closeButton.snp.left).offset(-12)
            $0.size.equalTo(FloatingActionButton.size)
        }

        view.addSubview(useButton)
        useButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(54)
        }

        view.addSubview(previewImageView)
        previewImageView.snp.makeConstraints {
            $0.centerY.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(previewImageView.snp.width)
            $0.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide.snp.top).offset(72)
            $0.bottom.lessThanOrEqualTo(useButton.snp.top).offset(-24)
        }
    }
}

// MARK: - PassthroughView
private final class PassthroughView: UIView {
    var passthroughExceptions: [UIView] = []

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in passthroughExceptions where view.frame.contains(point) {
            return super.hitTest(point, with: event)
        }
        return nil
    }
}
