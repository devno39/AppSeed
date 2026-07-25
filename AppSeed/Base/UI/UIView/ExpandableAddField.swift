//
//  ExpandableAddField.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

// A floating action button that springs open into a rounded text field. The icon morphs
// plus ↔ checkmark as text appears; submitting fires onAdd and keeps the field open.
final class ExpandableAddField: UIView {

    // MARK: - State
    private(set) var isExpanded = false

    // MARK: - Constants
    private let buttonSize: CGFloat = 48
    private let fieldGap: CGFloat = 8

    // MARK: - UI
    private lazy var fab: FloatingActionButton = {
        let fab = FloatingActionButton()
        fab.setIcon(name: Symbols.plus.symbolName, color: ColorText.textPrimary.color)
        fab.onTap = { [weak self] in self?.addTapped() }
        return fab
    }()

    private lazy var fieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = buttonSize / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = ColorBackground.backgroundBorder.color.cgColor
        view.clipsToBounds = true
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 40, y: 0)
        return view
    }()

    private lazy var textField: BaseTextField = {
        let field = BaseTextField()
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: ColorText.textSecondary.color.withAlphaComponent(0.5)]
        )
        field.backgroundColor = .clear
        field.returnKeyType = .default
        field.delegate = self
        field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return field
    }()

    // MARK: - Properties
    var placeholder: String {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: ColorText.textSecondary.color.withAlphaComponent(0.5)]
            )
        }
    }

    // MARK: - Closures
    var onAdd: AnyClosure<String>?

    // MARK: - Init
    init(placeholder: String = "") {
        self.placeholder = placeholder
        super.init(frame: .zero)
        draw()
        applyGlassIfAvailable()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func expand() {
        guard !isExpanded else { return }
        isExpanded = true
        textField.becomeFirstResponder()

        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.4,
            options: .curveEaseOut
        ) {
            self.fieldContainer.alpha = 1
            self.fieldContainer.transform = .identity
        }
    }

    func collapse() {
        guard isExpanded else { return }
        isExpanded = false
        textField.resignFirstResponder()
        textField.text = ""
        updateActionIcon()

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: .curveEaseIn
        ) {
            self.fieldContainer.alpha = 0
            self.fieldContainer.transform = CGAffineTransform(translationX: 40, y: 0)
        }
    }

    // MARK: - Glass
    private func applyGlassIfAvailable() {
        if #available(iOS 26, *) {
            fieldContainer.backgroundColor = .clear
            fieldContainer.layer.borderWidth = 0
            let effect = UIGlassEffect(style: .clear)
            effect.isInteractive = true
            let fieldGlass = UIVisualEffectView(effect: effect)
            fieldGlass.clipsToBounds = true
            fieldGlass.layer.cornerRadius = buttonSize / 2
            fieldContainer.insertSubview(fieldGlass, at: 0)
            fieldGlass.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }

    // MARK: - Actions
    @objc private func addTapped() {
        if !isExpanded {
            expand()
        } else if hasText {
            submit()
        } else {
            collapse()
        }
    }

    @objc private func textChanged() {
        updateActionIcon()
    }

    private func submit() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return }
        onAdd?(text)
        textField.text = ""
        updateActionIcon()
    }

    // MARK: - Helpers
    private var hasText: Bool {
        !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
    }

    private func updateActionIcon() {
        let name = hasText ? Symbols.checkmark.symbolName : Symbols.plus.symbolName
        let color = hasText ? Palette.palette1.color : ColorText.textPrimary.color
        fab.animateIcon(to: name, color: color)
    }
}

// MARK: - UITextFieldDelegate
extension ExpandableAddField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if hasText {
            submit()
        } else {
            collapse()
        }
        return false
    }
}

// MARK: - Draw
extension ExpandableAddField {
    private func draw() {
        addSubview(fieldContainer)
        addSubview(fab)
        fieldContainer.addSubview(textField)

        fab.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
        }

        fieldContainer.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(fab.snp.leading).offset(-fieldGap)
            $0.centerY.equalTo(fab)
            $0.height.equalTo(buttonSize)
        }

        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.bottom.equalToSuperview()
        }
    }
}
