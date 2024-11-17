//
//  UIView+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

extension UIView {
    func drawShadow(radius: CGFloat? = nil) {
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shadowRadius = radius ?? frame.width / 2
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
    }
    
    func roundCorners(_ corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight],
                      radius: CGFloat = 24, 
                      borderColor: UIColor? = nil,
                      borderWidth: CGFloat? = nil) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        
        if let borderColor = borderColor {
            layer.borderColor = borderColor.cgColor
        }
        if let borderWidth = borderWidth {
            layer.borderWidth = borderWidth
        }
    }
}
