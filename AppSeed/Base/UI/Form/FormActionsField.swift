//
//  FormActionsField.swift
//  AppSeed
//
//  Created by Claude on 12.07.2026.
//

import UIKit
import SnapKit

// MARK: - Form Action
struct FormAction {

    // MARK: - Style
    enum Style {
        case normal
        case destructive
    }

    let title: String
    let icon: String
    let style: Style
    let handler: EmptyClosure

    init(title: String, icon: String, style: Style = .normal, handler: @escaping EmptyClosure) {
        self.title = title
        self.icon = icon
        self.style = style
        self.handler = handler
    }
}

// MARK: - Field
final class FormActionsField: UIView {

    // MARK: - UI
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    // MARK: - Init
    init(actions: [FormAction]) {
        super.init(frame: .zero)
        draw()
        actions.forEach { stackView.addArrangedSubview(FormActionTileView(action: $0)) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Draw
extension FormActionsField {
    private func draw() {
        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(60)
        }
    }
}

// MARK: - Tile
private final class FormActionTileView: UIView, PaletteUpdatable {

    // MARK: - UI
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 11, fontWeight: .medium, textColor: ColorText.textPrimary.color)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        return label
    }()

    // MARK: - Properties
    private let action: FormAction

    // MARK: - Init
    init(action: FormAction) {
        self.action = action
        super.init(frame: .zero)
        titleLabel.text = action.title
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconView.image = UIImage(systemName: action.icon, withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        updateColors()
        draw()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions
    @objc private func handleTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
            }
        }
        action.handler()
    }

    // MARK: - Private
    private func updateColors() {
        iconView.tintColor = action.style == .destructive ? ColorAction.destructive.color : Palette.palette1.color
    }

    @objc dynamic func updatePaletteColors() {
        updateColors()
    }

    // MARK: - Draw
    private func draw() {
        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(6)
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
}
