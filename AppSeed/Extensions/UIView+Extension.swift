//
//  UIView+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

extension UIView {
    func drawShadow(radius: CGFloat, color: UIColor = ColorBackground.shadowPrimary.color, opacity: Float = 0.3) {
        layer.masksToBounds = false
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }
    
    func roundCorners(_ corners: UIRectCorner = .allCorners,
                      radius: CGFloat,
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
    
    func roundCornersWithShadow(radius: CGFloat,
                                corners: UIRectCorner = .allCorners,
                                color: UIColor = ColorBackground.shadowPrimary.color,
                                opacity: Float = 0.3,
                                borderColor: UIColor? = nil,
                                borderWidth: CGFloat? = nil) {
        roundCorners(corners ,radius: radius, borderColor: borderColor, borderWidth: borderWidth)
        drawShadow(radius: radius, color: color, opacity: opacity)
        layer.masksToBounds = false
    }
    
    func roundCornersTop(radius: CGFloat) {
        roundCorners([.topLeft, .topRight], radius: radius)
    }
    
    func roundCornersBottom(radius: CGFloat) {
        roundCorners([.bottomLeft, .bottomRight], radius: radius)
    }
}
