//
//  PillSearchField.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

// A glass/pill search field sized to fill a nav bar titleView. Placeholder is a parameter;
// text edits are surfaced through onTextChanged.
final class PillSearchField: UIView {

    // MARK: - Constants
    static let height: CGFloat = 40

    // MARK: - UI
    private lazy var textField: BaseTextField = {
        let field = BaseTextField()
        field.returnKeyType = .search
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: ColorText.textSecondary.color.withAlphaComponent(0.5)]
        )
        field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        return field
    }()

    // MARK: - Closure
    var onTextChanged: EmptyClosure?

    // MARK: - Properties
    private let placeholder: String

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    // MARK: - Init
    init(placeholder: String = "") {
        self.placeholder = placeholder
        super.init(frame: .zero)
        draw()
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Expanded width — otherwise a nav bar titleView shrinks to the placeholder width.
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.layoutFittingExpandedSize.width, height: PillSearchField.height)
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    // MARK: - Appearance
    private func setupAppearance() {
        if #available(iOS 26, *) {
            let effect = UIGlassEffect(style: .clear)
            effect.isInteractive = true
            let glass = UIVisualEffectView(effect: effect)
            glass.clipsToBounds = true
            glass.layer.cornerRadius = PillSearchField.height / 2
            insertSubview(glass, at: 0)
            glass.snp.makeConstraints { $0.edges.equalToSuperview() }
        } else {
            backgroundColor = ColorBackground.backgroundSecondary.color
            layer.cornerRadius = PillSearchField.height / 2
            layer.borderWidth = 1
            layer.borderColor = ColorBackground.backgroundBorder.color.cgColor
        }
    }

    // MARK: - Actions
    @objc private func textChanged() {
        onTextChanged?()
    }
}

// MARK: - Draw
extension PillSearchField {
    private func draw() {
        addSubview(textField)

        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.bottom.equalToSuperview()
        }
    }
}
