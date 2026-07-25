//
//  ProfileActionCell.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

final class ProfileActionCell: BaseTVCell {

    private static let iconWidth: CGFloat = 22

    // MARK: - UI
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = ColorBackground.backgroundBorder.color.cgColor
        return view
    }()

    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = Palette.palette1.color
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorText.textPrimary.color
        label.numberOfLines = 1
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = ColorText.textSecondary.color
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    private lazy var chevronView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = ColorText.textSecondary.color
        view.image = Symbols.chevron_right.symbolSmall()
        return view
    }()

    // MARK: - Properties
    private var isDestructive = false

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabel.isHidden = true
        iconView.image = nil
        iconView.tintColor = Palette.palette1.color
        chevronView.isHidden = false
        isDestructive = false
        textStack.alignment = .center
    }

    // MARK: - Configure
    func configure(with model: ProfileCellType) {
        titleLabel.text = model.title
        isDestructive = model.isDestructive

        let hasSubtitle = model.subtitle != nil
        subtitleLabel.text = model.subtitle
        subtitleLabel.isHidden = !hasSubtitle
        textStack.alignment = hasSubtitle ? .leading : .center

        let tint = isDestructive ? ColorAction.destructive.color : Palette.palette1.color
        titleLabel.textColor = isDestructive ? ColorAction.destructive.color : ColorText.textPrimary.color

        if let icon = model.icon {
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            iconView.image = UIImage(systemName: icon, withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = tint
            iconView.isHidden = false
        } else {
            iconView.isHidden = true
        }

        chevronView.isHidden = !model.showsChevron
    }
}

// MARK: - PaletteUpdatable
extension ProfileActionCell {
    override func updatePaletteColors() {
        guard !isDestructive else { return }
        iconView.tintColor = Palette.palette1.color
    }
}

// MARK: - Draw
extension ProfileActionCell {
    private func draw() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(textStack)
        containerView.addSubview(chevronView)

        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().offset(-6)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.height.greaterThanOrEqualTo(54)
        }

        iconView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(Self.iconWidth)
        }

        chevronView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }

        textStack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(iconView.snp.right).offset(12)
            $0.right.lessThanOrEqualTo(chevronView.snp.left).offset(-12)
        }
    }
}
