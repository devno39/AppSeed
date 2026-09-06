//
//  FloatingActionButton.swift
//  AppSeed
//
//  Created by Claude on 01.03.2026.
//

import UIKit
import SnapKit

final class FloatingActionButton: UIView {

    // MARK: - Constants
    static let size: CGFloat = 48
    static let bottomPadding: CGFloat = 8
    static let contentPaddingAboveFAB: CGFloat = -8
    static let contentBottomInset: CGFloat = size + contentPaddingAboveFAB

    // MARK: - UI
    private var glassView: UIVisualEffectView?

    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Closure
    var onTap: EmptyClosure?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: FloatingActionButton.size, height: FloatingActionButton.size)
    }

    // MARK: - Public
    func setIcon(name: String, color: UIColor) {
        // Match nav bar button glyphs — 16 medium for visual parity.
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconView.image = UIImage(systemName: name, withConfiguration: symbolConfig)?
            .withRenderingMode(.alwaysTemplate)
        iconView.tintColor = color
    }

    func animateIcon(to name: String, color: UIColor) {
        UIView.transition(with: iconView, duration: 0.2, options: .transitionCrossDissolve) {
            self.setIcon(name: name, color: color)
        }
    }

    // MARK: - Appearance
    private func setupAppearance() {
        if #available(iOS 26, *) {
            // Nav bar parity: clear interactive glass, brighter than regular.
            let effect = UIGlassEffect(style: .clear)
            effect.isInteractive = true
            let glass = UIVisualEffectView(effect: effect)
            glass.clipsToBounds = true
            glass.layer.cornerRadius = FloatingActionButton.size / 2
            addSubview(glass)
            glass.snp.makeConstraints { $0.edges.equalToSuperview() }
            glassView = glass
        } else {
            backgroundColor = ColorBackground.backgroundSecondary.color
            layer.cornerRadius = FloatingActionButton.size / 2
            layer.borderWidth = 1
            setBorderColor(ColorBackground.backgroundBorder.color)
        }
    }

    // MARK: - Actions
    @objc private func tapped() {
        UIView.animate(withDuration: 0.12, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseInOut) {
            self.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6) {
                self.transform = .identity
            }
        }
        onTap?()
    }
}

// MARK: - Draw
extension FloatingActionButton {
    private func draw() {
        // Icon inside contentView picks up the system vibrant foreground treatment.
        let iconHost: UIView = glassView?.contentView ?? self
        iconHost.addSubview(iconView)
        addSubview(button)

        iconView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.height.equalTo(FloatingActionButton.size)
        }
    }
}
