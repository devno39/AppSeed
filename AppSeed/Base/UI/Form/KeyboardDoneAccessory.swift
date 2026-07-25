//
//  KeyboardDoneAccessory.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import UIKit

final class KeyboardDoneAccessory: UIView {

    // MARK: - Properties
    private let onDone: () -> Void

    // MARK: - Init
    init(onDone: @escaping () -> Void) {
        self.onDone = onDone
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        autoresizingMask = .flexibleWidth
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Actions
    @objc private func doneTapped() {
        onDone()
    }

    // MARK: - Draw
    private func draw() {
        backgroundColor = UIColor(red: 0.13, green: 0.13, blue: 0.14, alpha: 1.0)

        let doneButton = UIButton(type: .system)
        doneButton.setTitle(Localizable.done, for: .normal)
        if let desc = UIFont.systemFont(ofSize: 16, weight: .medium).fontDescriptor.withDesign(.rounded) {
            doneButton.titleLabel?.font = UIFont(descriptor: desc, size: 16)
        } else {
            doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        }
        doneButton.setTitleColor(Palette.palette1.color, for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        addSubview(doneButton)

        doneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
