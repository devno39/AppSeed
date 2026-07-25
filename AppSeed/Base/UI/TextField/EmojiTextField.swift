//
//  EmojiTextField.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// Emoji-only keyboard field; caret/selection/menu suppressed so it acts as a
// tap-to-pick surface rather than a text-editing one.
final class EmojiTextField: UITextField {

    override var textInputMode: UITextInputMode? {
        UITextInputMode.activeInputModes.first { $0.primaryLanguage == "emoji" }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }
}
