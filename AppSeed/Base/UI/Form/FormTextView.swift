//
//  FormTextView.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import UIKit
import SnapKit

final class FormTextView: UIView {

    // MARK: - UI
    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .semibold, textColor: ColorText.textSecondary.color)
        return label
    }()

    private lazy var textView: UITextView = {
        let view = UITextView()
        if let descriptor = UIFont.systemFont(ofSize: 16, weight: .regular).fontDescriptor.withDesign(.rounded) {
            view.font = UIFont(descriptor: descriptor, size: 16)
        } else {
            view.font = .systemFont(ofSize: 16, weight: .regular)
        }
        view.textColor = ColorText.textPrimary.color
        view.tintColor = Palette.palette1.color
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.delegate = self
        view.isScrollEnabled = false
        view.inputAccessoryView = KeyboardDoneAccessory { [weak view] in
            view?.resignFirstResponder()
        }
        return view
    }()

    private lazy var placeholderLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 16, fontWeight: .regular, textColor: ColorText.textSecondary.color.withAlphaComponent(0.5))
        label.isUserInteractionEnabled = false
        return label
    }()

    // MARK: - Properties
    private let placeholderText: String
    private let showsToolbar: Bool

    // MARK: - Closure
    var onTextChange: AnyClosure<String>?

    // MARK: - Init
    init(title: String, placeholder: String = "", showsToolbar: Bool = false) {
        self.placeholderText = placeholder
        self.showsToolbar = showsToolbar
        super.init(frame: .zero)
        titleLabel.text = title
        placeholderLabel.text = placeholder
        if !showsToolbar {
            textView.inputAccessoryView = nil
        }
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    func setText(_ text: String?) {
        textView.text = text
        placeholderLabel.isHidden = !(text?.isEmpty ?? true)
    }
}

// MARK: - UITextViewDelegate
extension FormTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        onTextChange?(textView.text)
        invalidateIntrinsicContentSize()
    }
}

// MARK: - PaletteUpdatable
extension FormTextView: PaletteUpdatable {
    @objc dynamic func updatePaletteColors() {
        textView.tintColor = Palette.palette1.color
    }
}

// MARK: - Draw
extension FormTextView {
    private func draw() {
        addSubview(titleLabel)
        addSubview(textView)
        textView.addSubview(placeholderLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }

        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.greaterThanOrEqualTo(80)
            $0.bottom.equalToSuperview()
        }

        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}
