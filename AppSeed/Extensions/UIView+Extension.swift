//
//  UIView+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

extension UIView {
    func drawShadow(radius: CGFloat, color: UIColor? = ColorBackground.shadowPrimary.color, opacity: Float = 0.3, offset: CGSize = .zero) {
        layer.masksToBounds = false
        layer.shadowRadius = radius
        layer.shadowColor = color?.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
//        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
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
                                color: UIColor? = ColorBackground.shadowPrimary.color,
                                opacity: Float = 0.3,
                                offset: CGSize = .zero,
                                borderColor: UIColor? = nil,
                                borderWidth: CGFloat? = nil) {
        roundCorners(corners ,radius: radius, borderColor: borderColor, borderWidth: borderWidth)
        drawShadow(radius: radius, color: color, opacity: opacity, offset: offset)
        layer.masksToBounds = false
    }
    
    func roundCornersWithShadow(radius: CGFloat,
                                shadowRadius: CGFloat,
                                corners: UIRectCorner = .allCorners,
                                color: UIColor? = ColorBackground.shadowPrimary.color,
                                opacity: Float = 0.3,
                                offset: CGSize = .zero,
                                borderColor: UIColor? = nil,
                                borderWidth: CGFloat? = nil) {
        roundCorners(corners ,radius: radius, borderColor: borderColor, borderWidth: borderWidth)
        drawShadow(radius: shadowRadius, color: color, opacity: opacity, offset: offset)
        layer.masksToBounds = false
    }
    
    func roundCornersTop(radius: CGFloat) {
        roundCorners([.topLeft, .topRight], radius: radius)
    }
    
    func roundCornersBottom(radius: CGFloat) {
        roundCorners([.bottomLeft, .bottomRight], radius: radius)
    }
    
    func wrapped(with insets: UIEdgeInsets = .zero) -> UIView {
        let view = UIView()
        view.addSubview(self)
        self.snp.makeConstraints {
            $0.top.equalToSuperview().offset(insets.top)
            $0.bottom.equalToSuperview().offset(-insets.bottom)
            $0.left.equalToSuperview().offset(insets.left)
            $0.right.equalToSuperview().offset(-insets.right)
        }
        return view
    }
}
