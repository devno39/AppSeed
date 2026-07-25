//
//  UIViewAnimation+Extension.swift
//  AppSeed
//
//  Created by Claude on 19.01.2025.
//

import UIKit

// MARK: - Sparkle Intensity
enum SparkleIntensity {
    case low    // index0 - minimal
    case medium // index1 - moderate
    case high   // index2 - maximum
}

// MARK: - Glow Intensity
enum GlowIntensity {
    case low     // Subtle glow
    case medium  // Moderate glow
    case high    // Strong glow
    case unified // Synchronized glow for index2
}

// MARK: - UIView Sparkle Extension
extension UIView {

    func createSparkles(
        intensity: SparkleIntensity,
        centerY: CGFloat,
        centerX: CGFloat,
        palette1: UIColor,
        palette2: UIColor,
        sparkleImage: CGImage
    ) -> CAEmitterLayer {
        // Determine values based on intensity
        let birthRate: Float
        let lifetime: Float
        let velocity: CGFloat
        let emitterWidth: CGFloat

        switch intensity {
        case .low:
            birthRate = 3
            lifetime = 1.8
            velocity = 25
            emitterWidth = 80
        case .medium:
            birthRate = 7
            lifetime = 2.2
            velocity = 35
            emitterWidth = 110
        case .high:
            birthRate = 12
            lifetime = 2.5
            velocity = 50
            emitterWidth = 140
        }

        // Create a container layer for both emitters
        let container = CAEmitterLayer()

        // Top emitter - sparkles floating upward
        let topEmitter = CAEmitterLayer()
        topEmitter.emitterPosition = CGPoint(x: centerX, y: centerY - 80)
        topEmitter.emitterSize = CGSize(width: emitterWidth, height: 30)
        topEmitter.emitterShape = .rectangle
        topEmitter.renderMode = .additive

        let topCell = CAEmitterCell()
        topCell.contents = sparkleImage
        topCell.birthRate = birthRate
        topCell.lifetime = lifetime
        topCell.lifetimeRange = 0.8

        // Float upward
        topCell.velocity = -velocity
        topCell.velocityRange = velocity / 2
        topCell.yAcceleration = -velocity / 3

        // Spread horizontally but limited vertically
        topCell.emissionRange = CGFloat.pi / 2.5  // Wider spread
        topCell.spinRange = CGFloat.pi

        topCell.scale = 0.06
        topCell.scaleRange = 0.25
        topCell.scaleSpeed = 0.08

        topCell.color = palette1.cgColor
        topCell.alphaRange = 0.4

        topEmitter.emitterCells = [topCell]

        // Bottom emitter - sparkles floating downward
        let bottomEmitter = CAEmitterLayer()
        bottomEmitter.emitterPosition = CGPoint(x: centerX, y: centerY + 80)
        bottomEmitter.emitterSize = CGSize(width: emitterWidth, height: 30)
        bottomEmitter.emitterShape = .rectangle
        bottomEmitter.renderMode = .additive

        let bottomCell = CAEmitterCell()
        bottomCell.contents = sparkleImage
        bottomCell.birthRate = birthRate
        bottomCell.lifetime = lifetime
        bottomCell.lifetimeRange = 0.8

        // Float downward
        bottomCell.velocity = velocity
        bottomCell.velocityRange = velocity / 2
        bottomCell.yAcceleration = velocity / 3

        // Spread horizontally but limited vertically
        bottomCell.emissionRange = CGFloat.pi / 2.5  // Wider spread
        bottomCell.spinRange = CGFloat.pi

        bottomCell.scale = 0.06
        bottomCell.scaleRange = 0.25
        bottomCell.scaleSpeed = 0.08

        bottomCell.color = palette2.cgColor
        bottomCell.alphaRange = 0.4

        bottomEmitter.emitterCells = [bottomCell]

        // Add both emitters as sublayers
        container.addSublayer(topEmitter)
        container.addSublayer(bottomEmitter)

        // Fade in sparkles
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0
        fadeIn.toValue = 1
        fadeIn.duration = 1.0
        fadeIn.fillMode = .forwards
        fadeIn.isRemovedOnCompletion = false
        container.add(fadeIn, forKey: "fadeIn")

        return container
    }

    // MARK: - Glow Animation
    func startGlowAnimation(
        color: UIColor,
        intensity: GlowIntensity = .medium,
        shadowRadius: CGFloat = 30
    ) {
        // Set up shadow properties
        layer.shadowColor = color.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = shadowRadius

        // Determine animation values based on intensity
        let opacityValues: [CGFloat]
        let radiusValues: [CGFloat]
        let duration: TimeInterval

        switch intensity {
        case .low:
            opacityValues = [0.15, 0.3, 0.2, 0.25, 0.15]
            radiusValues = [20, 30, 25, 28, 20]
            duration = 2.5
        case .medium:
            opacityValues = [0.2, 0.4, 0.25, 0.35, 0.2]
            radiusValues = [22, 35, 28, 32, 22]
            duration = 2.2
        case .high:
            opacityValues = [0.3, 0.5, 0.35, 0.45, 0.3]
            radiusValues = [25, 45, 30, 40, 25]
            duration = 2.0
        case .unified:
            opacityValues = [0.35, 0.7, 0.45, 0.65, 0.35]
            radiusValues = [25, 50, 30, 45, 25]
            duration = 2.0
        }

        let keyTimes: [NSNumber] = [0, 0.2, 0.4, 0.7, 1]

        // Glow opacity animation
        let glowAnimation = CAKeyframeAnimation(keyPath: "shadowOpacity")
        glowAnimation.values = opacityValues
        glowAnimation.keyTimes = keyTimes
        glowAnimation.duration = duration
        glowAnimation.repeatCount = .infinity

        // Glow radius animation
        let radiusAnimation = CAKeyframeAnimation(keyPath: "shadowRadius")
        radiusAnimation.values = radiusValues
        radiusAnimation.keyTimes = keyTimes
        radiusAnimation.duration = duration
        radiusAnimation.repeatCount = .infinity

        layer.add(glowAnimation, forKey: "glowAnimation")
        layer.add(radiusAnimation, forKey: "glowRadiusAnimation")
    }

    func stopGlowAnimation() {
        layer.removeAnimation(forKey: "glowAnimation")
        layer.removeAnimation(forKey: "glowRadiusAnimation")
    }

    // MARK: - Breathing Animation (Premium Style)
    func startBreathingAnimation(
        duration: TimeInterval = 3.0,
        scaleRange: CGFloat = 0.03
    ) {
        let breathing = CAKeyframeAnimation(keyPath: "transform.scale")
        breathing.values = [1.0, 1.0 + scaleRange, 1.0 - scaleRange * 0.5, 1.0 + scaleRange * 0.66, 1.0]
        breathing.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        breathing.duration = duration
        breathing.repeatCount = .infinity
        breathing.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer.add(breathing, forKey: "breathingAnimation")
    }

    func stopBreathingAnimation() {
        layer.removeAnimation(forKey: "breathingAnimation")
    }

    // MARK: - Nudge Shake
    func playNudgeShake() {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.values = [0, -12, 12, -9, 9, -6, 6, -3, 3, 0]
        shake.duration = 0.7
        shake.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(shake, forKey: "nudgeShake")

        let tilt = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        tilt.values = [0, -0.09, 0.09, -0.06, 0.06, 0]
        tilt.duration = 0.7
        layer.add(tilt, forKey: "nudgeTilt")
    }

    // MARK: - Premium Glow
    func startPremiumGlow() {
        clipsToBounds = false
        layer.masksToBounds = false

        layer.shadowColor = Palette.palette1.color.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 20
        layer.shadowOffset = .zero

        let glowBounds = bounds.insetBy(dx: 8, dy: 8)
        layer.shadowPath = UIBezierPath(ovalIn: glowBounds).cgPath
    }

    func stopPremiumGlow() {
        layer.shadowOpacity = 0
    }

    static func createSparkleImage() -> CGImage {
        let size: CGFloat = 20
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return blankCGImage
        }

        // Draw a 4-pointed star
        context.setFillColor(UIColor.white.cgColor)
        context.move(to: CGPoint(x: size / 2, y: 0))
        context.addLine(to: CGPoint(x: size * 0.6, y: size * 0.4))
        context.addLine(to: CGPoint(x: size, y: size / 2))
        context.addLine(to: CGPoint(x: size * 0.6, y: size * 0.6))
        context.addLine(to: CGPoint(x: size / 2, y: size))
        context.addLine(to: CGPoint(x: size * 0.4, y: size * 0.6))
        context.addLine(to: CGPoint(x: 0, y: size / 2))
        context.addLine(to: CGPoint(x: size * 0.4, y: size * 0.4))
        context.closePath()
        context.fillPath()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.cgImage ?? blankCGImage
    }

    // Guaranteed-valid 1×1 RGBA bitmap — replaces UIImage().cgImage! (which is always nil → crash).
    private static let blankCGImage: CGImage = {
        let context = CGContext(
            data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        // 1×1 RGBA8 are always-valid params — makeImage on a valid context never fails in practice.
        return context!.makeImage()!
    }()
}
