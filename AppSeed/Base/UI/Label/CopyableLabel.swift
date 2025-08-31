//
//  CopyableLabel.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import UIKit

final class CopyableLabel: BaseLabel {
    override var canBecomeFirstResponder: Bool { true }

    override init(fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .regular, textColor: UIColor = ColorText.textPrimary.color) {
        super.init(fontSize: fontSize, fontWeight: fontWeight, textColor: textColor)
        enableCopyGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        enableCopyGesture()
    }

    private func enableCopyGesture() {
        isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showMenu))
        addGestureRecognizer(longPress)
    }

    @objc private func showMenu(_ sender: UILongPressGestureRecognizer) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.showMenu(from: self, rect: bounds)
        }
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
}
