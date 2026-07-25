//
//  FormTextField.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import UIKit
import SnapKit

final class FormTextField: UIView, UITextFieldDelegate {

    // MARK: - UI
    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .semibold, textColor: ColorText.textSecondary.color)
        return label
    }()

    private lazy var textField: BaseTextField = {
        let field = BaseTextField()
        field.backgroundColor = ColorBackground.backgroundSecondary.color
        field.layer.cornerRadius = 12
        field.layer.masksToBounds = true
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        field.returnKeyType = .done
        field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return field
    }()

    // MARK: - Closure
    var onTextChange: AnyClosure<String>?

    // MARK: - Init
    init(title: String, placeholder: String? = nil) {
        super.init(frame: .zero)
        titleLabel.text = title
        textField.delegate = self
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor: ColorText.textSecondary.color.withAlphaComponent(0.5)]
        )
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func setText(_ text: String?) {
        textField.text = text
    }

    // Read-only mode — text color stays normal, only touch handling is disabled.
    func setEnabled(_ enabled: Bool) {
        textField.isUserInteractionEnabled = enabled
    }

    // MARK: - Actions
    @objc private func textChanged() {
        onTextChange?(textField.text ?? "")
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Draw
extension FormTextField {
    private func draw() {
        addSubview(titleLabel)
        addSubview(textField)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }
    }
}
