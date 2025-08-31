//
//  BaseLabel.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import UIKit

class BaseLabel: UILabel {
    // MARK: - Init
    init(fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .regular, textColor: UIColor = ColorText.textPrimary.color) {
        super.init(frame: .zero)
        defaultAppearance(fontSize: fontSize, fontWeight: fontWeight, color: textColor)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultAppearance()
    }

    // MARK: - Default
    private func defaultAppearance(fontSize: CGFloat = 16, fontWeight: UIFont.Weight = .regular, color: UIColor = ColorText.textPrimary.color) {
        if let descriptor = UIFont.systemFont(ofSize: fontSize, weight: fontWeight).fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: fontSize)
        } else {
            font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
        textColor = color
        numberOfLines = 0
        textAlignment = .left
    }
    
    // MARK: - SetText with LineSpacing
    func setText(_ text: String?, lineSpacing: CGFloat) {
        guard let text else { return }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font as Any,
            .foregroundColor: textColor as Any,
            .paragraphStyle: style
        ]
        
        attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
