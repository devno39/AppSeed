//
//  FormEmojiField.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import UIKit
import SnapKit

final class FormEmojiField: UIView {

    // MARK: - UI
    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .semibold, textColor: ColorText.textSecondary.color)
        return label
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: Symbols.plus.symbolName, withConfiguration: config), for: .normal)
        button.tintColor = ColorText.textSecondary.color
        button.backgroundColor = ColorBackground.backgroundSecondary.color
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1.5
        button.layer.borderColor = ColorBackground.backgroundBorder.color.cgColor
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var hiddenTextField: EmojiTextField = {
        let field = EmojiTextField()
        field.delegate = self
        field.backgroundColor = .clear
        field.tintColor = .clear
        field.textColor = .clear
        return field
    }()

    // MARK: - Properties
    private let emojis: [String]
    private var selectedIndex: Int? = 0
    private var customEmoji: String?
    private var emojiButtons: [UIButton] = []

    // MARK: - Defaults
    static let dateEmojis = ["🗓️", "❤️", "🎂", "💍", "🎉", "✈️"]
    static let taskListEmojis = ["📋", "🛒", "🍳", "🏠", "🎯", "✈️"]
    static let placeEmojis = ["📍", "🏠", "💼", "☕", "🍽️", "🌳"]
    static let missionEmojis = ["📌", "🧹", "🛒", "💰", "🏠", "📞"]

    // MARK: - Closure
    var onEmojiChange: AnyClosure<String?>?

    // MARK: - Init
    init(title: String, emojis: [String] = FormEmojiField.dateEmojis) {
        self.emojis = emojis
        super.init(frame: .zero)
        titleLabel.text = title
        draw()
        buildEmojiButtons()
        updateSelection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func setEmoji(_ emoji: String) {
        if let index = emojis.firstIndex(of: emoji) {
            customEmoji = nil
            selectedIndex = index
        } else {
            selectedIndex = nil
            customEmoji = emoji
        }
        updateSelection()
    }

    var selectedEmoji: String? {
        if let customEmoji {
            return customEmoji
        }
        guard let selectedIndex else { return nil }
        return emojis[selectedIndex]
    }

    // MARK: - Actions
    @objc private func emojiTapped(_ sender: UIButton) {
        let index = sender.tag
        customEmoji = nil

        if selectedIndex == index {
            selectedIndex = nil
            updateSelection()
            onEmojiChange?(nil)
        } else {
            selectedIndex = index
            updateSelection()
            onEmojiChange?(emojis[index])
        }
    }

    @objc private func addButtonTapped() {
        hiddenTextField.text = ""
        hiddenTextField.becomeFirstResponder()
    }

    // MARK: - Private
    private func buildEmojiButtons() {
        for (index, emoji) in emojis.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(emoji, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 22)
            button.backgroundColor = ColorBackground.backgroundSecondary.color
            button.layer.cornerRadius = 12
            button.layer.borderWidth = 0
            button.layer.borderColor = Palette.palette1.color.cgColor
            button.tag = index
            button.addTarget(self, action: #selector(emojiTapped(_:)), for: .touchUpInside)

            button.snp.makeConstraints {
                $0.width.height.equalTo(44)
            }

            stackView.addArrangedSubview(button)
            emojiButtons.append(button)
        }

        addButton.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        stackView.addArrangedSubview(addButton)
    }

    private func updateSelection() {
        for (index, button) in emojiButtons.enumerated() {
            let isSelected = (customEmoji == nil) && (index == selectedIndex)
            button.layer.borderWidth = isSelected ? 2 : 0
            button.backgroundColor = isSelected
                ? ColorBackground.backgroundTertiary.color
                : ColorBackground.backgroundSecondary.color
        }

        let addSelected = customEmoji != nil
        addButton.layer.borderWidth = addSelected ? 2 : 1.5
        addButton.layer.borderColor = addSelected
            ? Palette.palette1.color.cgColor
            : ColorBackground.backgroundBorder.color.cgColor
        addButton.backgroundColor = addSelected
            ? ColorBackground.backgroundTertiary.color
            : ColorBackground.backgroundSecondary.color

        if let customEmoji {
            addButton.setImage(nil, for: .normal)
            addButton.setTitle(customEmoji, for: .normal)
            addButton.titleLabel?.font = .systemFont(ofSize: 22)
        } else {
            addButton.setTitle(nil, for: .normal)
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            addButton.setImage(UIImage(systemName: Symbols.plus.symbolName, withConfiguration: config), for: .normal)
            addButton.tintColor = ColorText.textSecondary.color
        }
    }

    private func handleEmojiInput(_ emoji: String) {
        selectedIndex = nil
        customEmoji = emoji
        updateSelection()
        onEmojiChange?(emoji)
        hiddenTextField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension FormEmojiField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.isEmpty else { return false }

        if string.unicodeScalars.contains(where: { $0.properties.isEmoji && $0.properties.isEmojiPresentation }) {
            handleEmojiInput(string)
            return false
        }
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Draw
extension FormEmojiField {
    private func draw() {
        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(hiddenTextField)
        hiddenTextField.snp.makeConstraints { $0.size.equalTo(0); $0.leading.top.equalToSuperview() }
        scrollView.addSubview(stackView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
    }
}
