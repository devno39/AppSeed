//
//  ToastView.swift
//  AppSeed
//
//  Created by Claude on 30.03.2026.
//

import UIKit
import SnapKit

final class ToastView: UIView {

    // MARK: - UI
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        return stack
    }()

    private lazy var iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        view.layer.cornerRadius = 20
        return view
    }()

    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = Palette.palette1.color
        return view
    }()

    private lazy var labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 14, fontWeight: .semibold, textColor: ColorText.textPrimary.color)
        label.numberOfLines = 1
        return label
    }()

    private lazy var subtitleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 12, fontWeight: .regular, textColor: ColorText.textSecondary.color)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Init
    init(icon: String?, title: String, subtitle: String?) {
        super.init(frame: .zero)
        configure(icon: icon, title: title, subtitle: subtitle)
        draw()
        setupPanDismiss()
        observeAppearanceChanges()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Appearance
    // Self-observes palette — global toasts attach to the key window, bypassing BaseViewController's traversal.
    private func observeAppearanceChanges() {
        // .themeDidChange joins this list once ThemeManager lands (Phase 1 commit 3)
        [Notification.Name.paletteDidChange].forEach {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updatePaletteColors),
                name: $0,
                object: nil
            )
        }
    }

    // MARK: - Configure
    private func configure(icon: String?, title: String, subtitle: String?) {
        titleLabel.text = title

        if let icon {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            iconView.image = UIImage(systemName: icon, withConfiguration: config)
        } else {
            iconView.isHidden = true
        }

        if let subtitle {
            subtitleLabel.text = subtitle
        } else {
            subtitleLabel.isHidden = true
        }
    }

    // MARK: - Gesture
    private func setupPanDismiss() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)

        switch gesture.state {
        case .changed:
            guard translation.y < 0 else { return }
            transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let velocity = gesture.velocity(in: self)
            if translation.y < -30 || velocity.y < -500 {
                ToastHelper.dismiss()
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.transform = .identity
                }
            }
        default:
            break
        }
    }
}

// MARK: - PaletteUpdatable
extension ToastView: PaletteUpdatable {
    @objc dynamic func updatePaletteColors() {
        backgroundView.backgroundColor = ColorBackground.backgroundPrimary.color
        iconContainerView.backgroundColor = ColorBackground.backgroundTertiary.color
        iconView.tintColor = Palette.palette1.color
        titleLabel.textColor = ColorText.textPrimary.color
        subtitleLabel.textColor = ColorText.textSecondary.color
    }
}

// MARK: - Draw
extension ToastView {
    private func draw() {
        addSubview(backgroundView)
        backgroundView.addSubview(stackView)

        if !iconView.isHidden {
            iconContainerView.addSubview(iconView)
            iconView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.height.equalTo(20)
            }
            stackView.addArrangedSubview(iconContainerView)
            iconContainerView.snp.makeConstraints {
                $0.width.height.equalTo(40)
            }
        }

        labelStack.addArrangedSubview(titleLabel)
        if !subtitleLabel.isHidden {
            labelStack.addArrangedSubview(subtitleLabel)
        }
        stackView.addArrangedSubview(labelStack)

        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
