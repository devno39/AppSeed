//
//  BaseTextField.swift
//  AppSeed
//
//  Created by Claude on 16.03.2026.
//

import UIKit

class BaseTextField: UITextField {

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultAppearance()
    }

    // MARK: - Default
    private func defaultAppearance() {
        tintColor = Palette.palette1.color
        if let descriptor = UIFont.systemFont(ofSize: 16, weight: .regular).fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: 16)
        } else {
            font = .systemFont(ofSize: 16, weight: .regular)
        }
        textColor = ColorText.textPrimary.color
        autocorrectionType = .no
    }
}

// MARK: - PaletteUpdatable
extension BaseTextField: PaletteUpdatable {
    @objc dynamic func updatePaletteColors() {
        tintColor = Palette.palette1.color
    }
}
