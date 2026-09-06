//
//  ItemCell.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import UIKit
import SnapKit

final class ItemCell: BaseTVCell {

    // MARK: - UI
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.setBorderColor(ColorBackground.backgroundBorder.color)
        return view
    }()

    private lazy var checkButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = Palette.palette1.color
        button.addTarget(self, action: #selector(checkTapped), for: .touchUpInside)
        return button
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorText.textPrimary.color
        label.numberOfLines = 1
        return label
    }()

    private lazy var noteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = ColorText.textSecondary.color
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, noteLabel])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    // MARK: - Constants
    private let checkSize: CGFloat = 26

    // MARK: - Closure
    var onToggle: EmptyClosure?

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        draw()
    }

    // MARK: - Configure
    func configure(with item: ItemModel) {
        titleLabel.text = item.title
        titleLabel.textColor = item.isDone ? ColorText.textSecondary.color : ColorText.textPrimary.color

        noteLabel.text = item.note
        noteLabel.isHidden = item.note.isEmpty

        emojiLabel.text = item.emoji
        emojiLabel.isHidden = item.emoji.isEmpty

        let symbol = item.isDone ? Symbols.checkmark_circle_fill : Symbols.circle
        checkButton.setImage(symbol.symbol(size: .custom(checkSize), weight: .regular), for: .normal)
    }

    // MARK: - Actions
    @objc private func checkTapped() {
        onToggle?()
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
    }

    // MARK: - Palette
    override func updatePaletteColors() {
        checkButton.tintColor = Palette.palette1.color
    }
}

// MARK: - Draw
extension ItemCell {
    private func draw() {
        contentView.addSubview(containerView)
        containerView.addSubview(checkButton)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(textStack)

        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        checkButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(checkSize)
        }

        emojiLabel.snp.makeConstraints {
            $0.leading.equalTo(checkButton.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(24)
        }

        textStack.snp.makeConstraints {
            $0.leading.equalTo(emojiLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.bottom.equalToSuperview().inset(14)
        }
    }
}
