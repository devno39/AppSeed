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
        roundCorners(corners, radius: radius, borderColor: borderColor, borderWidth: borderWidth)
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
        roundCorners(corners, radius: radius, borderColor: borderColor, borderWidth: borderWidth)
        drawShadow(radius: shadowRadius, color: color, opacity: opacity, offset: offset)
        layer.masksToBounds = false
    }

    func roundCornersTop(radius: CGFloat) {
        roundCorners([.topLeft, .topRight], radius: radius)
    }

    func roundCornersBottom(radius: CGFloat) {
        roundCorners([.bottomLeft, .bottomRight], radius: radius)
    }

    // MARK: - Pulse Animations
    func startPulseGlowAnimation(shadowColor: CGColor) {
        layer.shadowColor = shadowColor

        let opacity = CAKeyframeAnimation(keyPath: "shadowOpacity")
        opacity.values = [0, 0.25, 0.45, 0.25, 0.1, 0]
        opacity.keyTimes = [0, 0.15, 0.35, 0.5, 0.8, 1]
        opacity.duration = 1.5
        opacity.repeatCount = .infinity
        opacity.timingFunctions = [
            CAMediaTimingFunction(name: .easeIn),
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeIn),
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeOut)
        ]

        let radius = CAKeyframeAnimation(keyPath: "shadowRadius")
        radius.values = [16, 20, 28, 20, 18, 16]
        radius.keyTimes = opacity.keyTimes
        radius.duration = opacity.duration
        radius.repeatCount = .infinity
        radius.timingFunctions = opacity.timingFunctions

        layer.add(opacity, forKey: "pulseGlowOpacity")
        layer.add(radius, forKey: "pulseGlowRadius")
    }

    func startBreathingAnimation() {
        let breathing = CAKeyframeAnimation(keyPath: "transform.scale")
        breathing.values = [1.0, 0.992, 0.985, 0.992, 1.0]
        breathing.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        breathing.duration = 1.4
        breathing.repeatCount = .infinity
        breathing.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(breathing, forKey: "pulseBreathing")
    }

    func stopPulseAnimations() {
        layer.removeAnimation(forKey: "pulseGlowOpacity")
        layer.removeAnimation(forKey: "pulseGlowRadius")
        layer.removeAnimation(forKey: "pulseBreathing")
    }

    // MARK: - Cross Dissolve
    func crossDissolve(duration: TimeInterval = 0.25, _ changes: @escaping EmptyClosure) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: changes)
    }

    // MARK: - Shimmer Animation
    func startShimmer() {
        stopShimmer()

        let shimmerLayer = CAGradientLayer()
        shimmerLayer.name = "shimmer"
        shimmerLayer.frame = bounds
        shimmerLayer.cornerRadius = layer.cornerRadius
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)

        // Auto-resize with parent
        shimmerLayer.anchorPoint = .zero
        shimmerLayer.position = .zero
        shimmerLayer.bounds = bounds
        CATransaction.setDisableActions(true)

        let baseColor = ColorText.textSecondary.color.withAlphaComponent(0.05).cgColor
        let highlightColor = ColorText.textSecondary.color.withAlphaComponent(0.25).cgColor
        shimmerLayer.colors = [baseColor, highlightColor, baseColor]
        shimmerLayer.locations = [0, 0.5, 1]

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shimmerLayer.add(animation, forKey: "shimmerAnimation")

        layer.addSublayer(shimmerLayer)
    }

    func stopShimmer() {
        layer.sublayers?.removeAll { $0.name == "shimmer" }
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
