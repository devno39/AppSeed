//
//  ConfettiView.swift
//  AppSeed
//
//  Created by Claude on 17.03.2026.
//

import UIKit

final class ConfettiView: UIView {

    // MARK: - Properties
    private var emitterLayer: CAEmitterLayer?

    // MARK: - Show
    static func show(on viewController: UIViewController, duration: TimeInterval = 8.0, message: String? = nil, completion: EmptyClosure? = nil) {
        guard let window = viewController.view.window else {
            completion?()
            return
        }
        let confetti = ConfettiView(frame: window.bounds)
        confetti.isUserInteractionEnabled = false
        window.addSubview(confetti)
        confetti.startRain()

        // Overlay message
        if let message {
            confetti.showMessage(message)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            confetti.emitterLayer?.birthRate = 0
            UIView.animate(withDuration: 1.5, animations: {
                confetti.alpha = 0
            }) { _ in
                confetti.removeFromSuperview()
                completion?()
            }
        }
    }

    // MARK: - Message
    private func showMessage(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40)
        ])

        // Animate in — scale up + fade in
        UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            label.alpha = 1
            label.transform = .identity
        }

        // Animate out
        UIView.animate(withDuration: 0.5, delay: 3.0) {
            label.alpha = 0
            label.transform = CGAffineTransform(translationX: 0, y: -30)
        }
    }

    // MARK: - Confetti
    private func startRain() {
        let colors: [UIColor] = [
            Palette.palette1.color,
            Palette.palette2.color,
            Palette.palette3.color,
            Palette.palette1.color.withAlphaComponent(0.7),
            .white.withAlphaComponent(0.5)
        ]

        // Rain from above screen — particles enter naturally from top
        let rain = CAEmitterLayer()
        rain.emitterPosition = CGPoint(x: bounds.midX, y: -60)
        rain.emitterSize = CGSize(width: bounds.width * 1.5, height: 1)
        rain.emitterShape = .line
        rain.renderMode = .oldestLast
        rain.beginTime = CACurrentMediaTime()

        rain.emitterCells = colors.flatMap { color in
            ConfettiShape.allCases.map { shape in
                let cell = CAEmitterCell()
                cell.birthRate = 4
                cell.lifetime = 14
                cell.velocity = 130
                cell.velocityRange = 60
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 6
                cell.spin = 2.5
                cell.spinRange = 5
                cell.scale = shape.scale
                cell.scaleRange = shape.scale * 0.3
                cell.yAcceleration = CGFloat.random(in: 40...80)
                cell.xAcceleration = CGFloat.random(in: -15...15)
                cell.color = color.cgColor
                cell.contents = shape.image.cgImage
                cell.alphaSpeed = -0.03
                cell.beginTime = 0.01 // no pre-fill — particles start fresh
                return cell
            }
        }

        layer.addSublayer(rain)
        emitterLayer = rain
    }
}

// MARK: - Shape
private enum ConfettiShape: CaseIterable {
    case circle
    case strip
    case heart
    case star
    case diamond

    var scale: CGFloat {
        switch self {
        case .circle: return 0.18
        case .strip: return 0.22
        case .heart: return 0.20
        case .star: return 0.20
        case .diamond: return 0.18
        }
    }

    var image: UIImage {
        let size = CGSize(width: 16, height: 16)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor.white.cgColor)

            switch self {
            case .circle:
                ctx.fillEllipse(in: CGRect(x: 4, y: 4, width: 8, height: 8))

            case .strip:
                let path = UIBezierPath(roundedRect: CGRect(x: 5, y: 0, width: 6, height: 16), cornerRadius: 3)
                ctx.addPath(path.cgPath)
                ctx.fillPath()

            case .heart:
                let w = size.width
                let h = size.height
                let path = UIBezierPath()
                path.move(to: CGPoint(x: w / 2, y: h * 0.85))
                path.addCurve(to: CGPoint(x: w * 0.1, y: h * 0.35),
                              controlPoint1: CGPoint(x: w * 0.15, y: h * 0.7),
                              controlPoint2: CGPoint(x: w * 0.05, y: h * 0.55))
                path.addArc(withCenter: CGPoint(x: w * 0.3, y: h * 0.3), radius: w * 0.2,
                            startAngle: .pi, endAngle: 0, clockwise: true)
                path.addArc(withCenter: CGPoint(x: w * 0.7, y: h * 0.3), radius: w * 0.2,
                            startAngle: .pi, endAngle: 0, clockwise: true)
                path.addCurve(to: CGPoint(x: w / 2, y: h * 0.85),
                              controlPoint1: CGPoint(x: w * 0.95, y: h * 0.55),
                              controlPoint2: CGPoint(x: w * 0.85, y: h * 0.7))
                path.close()
                ctx.addPath(path.cgPath)
                ctx.fillPath()

            case .star:
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let path = UIBezierPath()
                for i in 0..<10 {
                    let radius: CGFloat = i % 2 == 0 ? 7 : 3
                    let angle = (CGFloat(i) * .pi / 5) - .pi / 2
                    let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
                    i == 0 ? path.move(to: point) : path.addLine(to: point)
                }
                path.close()
                ctx.addPath(path.cgPath)
                ctx.fillPath()

            case .diamond:
                let w = size.width
                let h = size.height
                let path = UIBezierPath()
                path.move(to: CGPoint(x: w / 2, y: 1))
                path.addLine(to: CGPoint(x: w - 3, y: h / 2))
                path.addLine(to: CGPoint(x: w / 2, y: h - 1))
                path.addLine(to: CGPoint(x: 3, y: h / 2))
                path.close()
                ctx.addPath(path.cgPath)
                ctx.fillPath()
            }
        }
    }
}
