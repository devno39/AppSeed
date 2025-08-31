//
//  UILabel+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import UIKit

extension UILabel {
    func setLineSpacing(_ spacing: CGFloat) {
        guard let text = text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        paragraphStyle.alignment = textAlignment
        
        let attributedString = NSAttributedString(
            string: text,
            attributes: [.paragraphStyle: paragraphStyle]
        )
        
        attributedText = attributedString
    }
}
