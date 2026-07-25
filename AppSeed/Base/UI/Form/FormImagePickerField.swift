//
//  FormImagePickerField.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import UIKit
import SnapKit

final class FormImagePickerField: UIView {

    // MARK: - UI
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var dashedBorder: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = ColorBackground.backgroundBorder.color.cgColor
        layer.fillColor = nil
        layer.lineDashPattern = [8, 6]
        layer.lineWidth = 2
        return layer
    }()

    private lazy var placeholderStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cameraIcon, addLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private lazy var cameraIcon: BaseImageView = {
        let imageView = BaseImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorText.textSecondary.color
        imageView.image = UIImage(systemName: Symbols.camera.symbolName)
        return imageView
    }()

    private lazy var addLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 14, fontWeight: .medium, textColor: ColorText.textSecondary.color)
        return label
    }()

    private lazy var cropImageView: CropImageView = {
        let view = CropImageView()
        view.isHidden = true
        return view
    }()

    // MARK: - Properties
    private let compact: Bool
    private var hasPickedNewImage = false

    // MARK: - Closure
    var onTap: EmptyClosure?
    var onUserInteraction: EmptyClosure? {
        get { cropImageView.onUserInteraction }
        set { cropImageView.onUserInteraction = newValue }
    }

    // MARK: - Init
    init(buttonTitle: String = "Add Photo", compact: Bool = false) {
        self.compact = compact
        super.init(frame: .zero)
        addLabel.text = buttonTitle
        draw()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.delegate = self
        containerView.addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashedBorder.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 16).cgPath
        dashedBorder.frame = containerView.bounds
    }

    // MARK: - Public
    func setImage(_ image: UIImage) {
        cropImageView.setImage(image)
        revealCropView()
        hasPickedNewImage = true
    }

    func setImageURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIImageView.retrieveImage(with: url) { [weak self] image in
            guard let self, let image else { return }
            DispatchQueue.main.async {
                self.cropImageView.setImage(image)
                self.revealCropView()
            }
        }
    }

    // Returns cropped image when a new photo is picked or the current one is panned/zoomed;
    // untouched profile → nil so the existing URL is kept and re-upload skipped.
    var croppedImage: UIImage? {
        guard hasPickedNewImage || cropImageView.hasUserInteracted else { return nil }
        return cropImageView.croppedImage
    }

    // MARK: - Actions
    @objc private func tapped() {
        onTap?()
    }

    // MARK: - Private
    private func revealCropView() {
        cropImageView.isHidden = false
        placeholderStack.isHidden = true
        dashedBorder.isHidden = true
    }
}

// MARK: - UIGestureRecognizerDelegate
// Tap waits for any pan to fail first — protects against false positives when
// the user begins a small drag on an image.
extension FormImagePickerField: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf other: UIGestureRecognizer) -> Bool {
        other is UIPanGestureRecognizer
    }
}

// MARK: - Draw
extension FormImagePickerField {
    private func draw() {
        addSubview(containerView)
        containerView.layer.addSublayer(dashedBorder)
        containerView.addSubview(cropImageView)
        containerView.addSubview(placeholderStack)

        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            if compact {
                $0.width.equalToSuperview().multipliedBy(0.5)
            } else {
                $0.leading.trailing.equalToSuperview()
            }
            $0.height.equalTo(containerView.snp.width)
        }

        placeholderStack.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        cameraIcon.snp.makeConstraints {
            $0.width.height.equalTo(32)
        }

        cropImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
