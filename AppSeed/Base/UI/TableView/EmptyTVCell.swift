//
//  EmptyTVCell.swift
//  AppSeed
//
//  Created by Codex on 25.02.2026.
//

import UIKit
import SnapKit

final class EmptyTVCell: BaseTVCell {
    // MARK: - UI
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .center
        return view
    }()
    private let iconView: BaseImageView = {
        let imageView = BaseImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorText.textSecondary.color
        return imageView
    }()
    private let titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 16, fontWeight: .medium, textColor: ColorText.textPrimary.color)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private let subtitleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 14, fontWeight: .regular, textColor: ColorText.textSecondary.color)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private lazy var actionButton: BaseButton = {
        let button = BaseButton(style: .primary)
        button.isHidden = true
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Closure
    var actionClosure: EmptyClosure?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    override func prepare() {
        super.prepare()
        backgroundColor = .clear
        draw()
    }

    // MARK: - Configure
    func configure(symbol: (any Symbolable)? = nil, title: String, subtitle: String? = nil, buttonTitle: String? = nil) {
        titleLabel.text = title
        subtitleLabel.text = subtitle

        if let symbol = symbol {
            iconView.isHidden = false
            iconView.image = symbol.symbol(tintColor: ColorText.textSecondary.color, size: .xxxLarge, weight: .regular)
        } else {
            iconView.isHidden = true
        }

        if let buttonTitle = buttonTitle {
            actionButton.isHidden = false
            actionButton.setTitle(buttonTitle, for: .normal)
        } else {
            actionButton.isHidden = true
        }
    }

    // MARK: - Actions
    @objc private func actionButtonTapped() {
        actionClosure?()
    }
}

// MARK: - Draw
extension EmptyTVCell {
    private func draw() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        stackView.addArrangedSubviews([iconView, titleLabel, subtitleLabel, actionButton])
        stackView.setCustomSpacing(4, after: titleLabel)
        stackView.setCustomSpacing(20, after: subtitleLabel)
        iconView.snp.makeConstraints {
            $0.width.height.equalTo(60)
        }
        titleLabel.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        actionButton.snp.makeConstraints {
            $0.height.equalTo(48)
            $0.width.equalToSuperview().offset(-48)
        }
    }
}
