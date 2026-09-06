//
//  FormSegmentField.swift
//  AppSeed
//
//  Created by Claude on 22.07.2026.
//

import UIKit
import SnapKit

final class FormSegmentField: UIView {

    // MARK: - UI
    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .semibold, textColor: ColorText.textSecondary.color)
        return label
    }()

    private lazy var segmentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    // MARK: - Source
    private let options: [String]
    private(set) var selectedIndex: Int
    private var segmentButtons: [UIButton] = []

    // MARK: - Closure
    var onSelectionChange: AnyClosure<Int>?

    // MARK: - Init
    init(title: String, options: [String], selectedIndex: Int) {
        self.options = options
        self.selectedIndex = max(0, min(selectedIndex, options.count - 1))
        super.init(frame: .zero)
        titleLabel.text = title
        draw()
        buildSegments()
        applySelection()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func setSelectedIndex(_ index: Int) {
        guard index >= 0, index < options.count else { return }
        selectedIndex = index
        applySelection()
    }

    // MARK: - Actions
    @objc private func segmentTapped(_ sender: UIButton) {
        guard sender.tag != selectedIndex else { return }
        selectedIndex = sender.tag
        applySelection()
        onSelectionChange?(selectedIndex)
    }

    // MARK: - Private
    // Buttons are loop-built from the options model at runtime.
    private func buildSegments() {
        for (index, title) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.layer.cornerRadius = 12
            button.layer.masksToBounds = true
            button.tag = index
            button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
            button.snp.makeConstraints { $0.height.equalTo(48) }
            segmentButtons.append(button)
            segmentStack.addArrangedSubview(button)
        }
    }

    // Selection look mirrors FormEmojiField: 2pt palette border on the active item.
    private func applySelection() {
        for (index, button) in segmentButtons.enumerated() {
            let isSelected = index == selectedIndex
            button.backgroundColor = isSelected
                ? ColorBackground.backgroundTertiary.color
                : ColorBackground.backgroundSecondary.color
            button.layer.borderWidth = isSelected ? 2 : 0
            button.setBorderColor(Palette.palette1.color)
            button.setTitleColor(isSelected ? ColorText.textPrimary.color : ColorText.textSecondary.color, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: isSelected ? .semibold : .medium)
        }
    }
}

// MARK: - Draw
extension FormSegmentField {
    private func draw() {
        addSubview(titleLabel)
        addSubview(segmentStack)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        segmentStack.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
