//
//  AvatarView.swift
//  AppSeed
//
//  Created by Claude on 21.01.2025.
//

import UIKit
import SnapKit

final class AvatarView: UIView, PaletteUpdatable {

    // MARK: - UI
    private lazy var imageView: BaseImageView = {
        let view = BaseImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        return view
    }()

    private lazy var placeholderImageView: BaseImageView = {
        let view = BaseImageView(frame: .zero)
        view.contentMode = .scaleAspectFit
        return view
    }()

    // MARK: - Properties
    private let placeholder: Logo
    private let showBorder: Bool

    // MARK: - Closure
    var onTap: EmptyClosure? {
        didSet {
            isUserInteractionEnabled = onTap != nil
            if onTap != nil, tapGesture.view == nil {
                addGestureRecognizer(tapGesture)
            }
        }
    }

    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))

    // MARK: - Init
    init(placeholder: Logo, showBorder: Bool = true) {
        self.placeholder = placeholder
        self.showBorder = showBorder
        super.init(frame: .zero)
        draw()
        updatePlaceholderImage()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = bounds.width / 2
        if showBorder {
            imageView.layer.borderWidth = 1
            imageView.setBorderColor(ColorBackground.backgroundBorder.color)
        }
    }

    // Small tappable avatars still get a ~44pt hit target.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard onTap != nil else { return super.point(inside: point, with: event) }
        let inset = min(0, (bounds.width - 44) / 2)
        return bounds.insetBy(dx: inset, dy: inset).contains(point)
    }

    // MARK: - Actions
    @objc private func handleTap() {
        onTap?()
    }

    // MARK: - Configure
    func configure(imageUrl: String?) {
        if let urlString = imageUrl, !urlString.isEmpty {
            imageView.setImage(with: urlString)
            placeholderImageView.isHidden = true
        } else {
            imageView.image = nil
            placeholderImageView.isHidden = false
        }
    }

    // MARK: - PaletteUpdatable
    @objc dynamic func updatePaletteColors() {
        updatePlaceholderImage()
    }

    // MARK: - Private
    private func updatePlaceholderImage() {
        placeholderImageView.image = placeholder.image.withPaletteGradient()
    }
}

// MARK: - Draw
extension AvatarView {
    private func draw() {
        addSubview(imageView)
        addSubview(placeholderImageView)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        placeholderImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.72)
            $0.height.equalToSuperview().multipliedBy(0.72)
        }
    }
}
