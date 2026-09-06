//
//  ProfileHeaderCell.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

final class ProfileHeaderCell: BaseTVCell {
    // MARK: - Constants
    private let avatarSize: CGFloat = 88
    private let editSize: CGFloat = 30
    // AvatarView placeholder renders at 72% of container; (88-72%)/2 keeps the pen on the bbox corner.
    private let placeholderPadding: CGFloat = 12

    // MARK: - Closures
    var editUserClosure: EmptyClosure?

    // MARK: - UI
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.setBorderColor(ColorBackground.backgroundBorder.color)
        return view
    }()

    private lazy var avatarGlow: UIView = {
        let view = UIView()
        view.layer.cornerRadius = avatarSize / 2
        view.layer.shadowColor = Palette.palette1.color.cgColor
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = .zero
        return view
    }()

    private lazy var avatarView: AvatarView = {
        AvatarView(placeholder: Logo.logo_1024, showBorder: false)
    }()

    private lazy var nameLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 18, fontWeight: .bold, textColor: ColorText.textPrimary.color)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var emailLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .regular, textColor: ColorText.textSecondary.color)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var editButton: BaseButton = {
        let button = BaseButton(style: .circle)
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        button.setImage(UIImage(systemName: "pencil", withConfiguration: config), for: .normal)
        button.setTitle(nil, for: .normal)
        button.tintColor = ColorText.textPrimary.color
        button.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return button
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        draw()
        addGestures()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        editUserClosure = nil
        nameLabel.text = nil
        emailLabel.text = nil
    }

    // MARK: - Configure
    func configure(with model: ProfileHeaderModel) {
        nameLabel.text = model.userName
        nameLabel.isHidden = model.userName == nil
        emailLabel.text = model.email
        emailLabel.isHidden = model.email == nil
        avatarView.configure(imageUrl: model.avatarURL)
    }

    // MARK: - Gestures
    private func addGestures() {
        avatarView.onTap = { [weak self] in
            self?.editUserClosure?()
        }
    }

    // MARK: - Actions
    @objc private func editTapped() {
        editUserClosure?()
    }
}

// MARK: - PaletteUpdatable
extension ProfileHeaderCell {
    override func updatePaletteColors() {
        avatarView.updatePaletteColors()
        avatarGlow.layer.shadowColor = Palette.palette1.color.cgColor
    }
}

// MARK: - Draw
extension ProfileHeaderCell {
    private func draw() {
        contentView.addSubview(containerView)
        containerView.addSubview(avatarGlow)
        avatarGlow.addSubview(avatarView)
        containerView.addSubview(textStack)
        containerView.addSubview(editButton)

        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        avatarGlow.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(avatarSize)
        }

        avatarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        editButton.snp.makeConstraints {
            $0.width.height.equalTo(editSize)
            $0.centerX.equalTo(avatarView.snp.trailing).offset(-placeholderPadding)
            $0.centerY.equalTo(avatarView.snp.bottom).offset(-placeholderPadding)
        }

        textStack.snp.makeConstraints {
            $0.top.equalTo(avatarGlow.snp.bottom).offset(12)
            $0.leading.greaterThanOrEqualToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().offset(-16)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
}
