//
//  LockedOverlay.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

// A tap-to-unlock overlay: a centered lock capsule over a transparent, full-bleed hit area.
// show(on:) pins it into a parent; the whole surface forwards taps to onTap.
final class LockedOverlay: UIView {

    // MARK: - Constants
    private let badgeSize: CGFloat = 48

    // MARK: - UI
    private lazy var badgeButton: UIButton = {
        let button: UIButton
        if #available(iOS 26, *) {
            var config = UIButton.Configuration.glass()
            config.cornerStyle = .capsule
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            config.image = UIImage(systemName: Symbols.lock_fill.symbolName, withConfiguration: symbolConfig)?
                .withRenderingMode(.alwaysTemplate)
            config.baseForegroundColor = ColorText.textSecondary.color
            button = UIButton(configuration: config)
        } else {
            button = UIButton(type: .system)
            button.backgroundColor = ColorBackground.backgroundSecondary.color
            button.layer.cornerRadius = badgeSize / 2
            button.layer.borderWidth = 1
            button.setBorderColor(ColorBackground.backgroundBorder.color)
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            let image = UIImage(systemName: Symbols.lock_fill.symbolName, withConfiguration: symbolConfig)?
                .withTintColor(ColorText.textSecondary.color, renderingMode: .alwaysOriginal)
            button.setImage(image, for: .normal)
        }
        button.isUserInteractionEnabled = false
        return button
    }()

    // MARK: - Properties
    var onTap: EmptyClosure?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        isUserInteractionEnabled = true
        backgroundColor = .clear

        addSubview(badgeButton)
        badgeButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(badgeSize)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    // MARK: - Actions
    @objc private func handleTap() {
        onTap?()
    }

    // MARK: - Public
    func show(on parentView: UIView) {
        guard superview == nil else { return }
        parentView.addSubview(self)
        snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func hide() {
        removeFromSuperview()
    }
}
