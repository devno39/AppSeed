//
//  PaperBackgroundView.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// A textured "paper" surface drawn in Core Graphics: selectable base color, an optional
// ruling pattern (lines/dots/grid), fiber grain, and a soft edge vignette.
final class PaperBackgroundView: UIView {

    // MARK: - Paper Config
    struct PaperConfig {
        let color: UIColor
        let pattern: Pattern

        enum Pattern {
            case plain
            case lined
            case dotted
            case grid
        }
    }

    // MARK: - Presets
    static let colors: [(id: String, name: String, color: UIColor)] = [
        ("kraft", "Kraft", UIColor(red: 0.78, green: 0.63, blue: 0.46, alpha: 1.0)),
        ("white", "White", .white),
        ("black", "Black", UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)),
        ("pink", "Pink", UIColor(red: 1.0, green: 0.87, blue: 0.88, alpha: 1.0)),
        ("blue", "Blue", UIColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1.0)),
        ("mint", "Mint", UIColor(red: 0.85, green: 0.97, blue: 0.90, alpha: 1.0)),
    ]

    static let patterns: [(id: String, name: String, pattern: PaperConfig.Pattern)] = [
        ("plain", "Plain", .plain),
        ("lined", "Lined", .lined),
        ("dotted", "Dotted", .dotted),
        ("grid", "Grid", .grid),
    ]

    // MARK: - Properties
    private var config = PaperConfig(color: .white, pattern: .plain)

    var currentColor: UIColor { config.color }

    // MARK: - Constants
    // Pattern spacing is proportional (counts-per-axis) — keeps density identical across sizes.
    private let linesPerHeight: CGFloat = 14
    private let dotsPerWidth: CGFloat = 16
    private let gridCellsPerWidth: CGFloat = 16

    private var patternColor: UIColor {
        // Dark patterns on light paper, light patterns on dark paper
        config.color.isLight
            ? UIColor.black.withAlphaComponent(0.08)
            : UIColor.white.withAlphaComponent(0.12)
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(colorId: String, patternId: String) {
        let color: UIColor
        if colorId.hasPrefix("#") {
            color = UIColor(hex: colorId) ?? .white
        } else {
            color = Self.colors.first { $0.id == colorId }?.color ?? .white
        }

        let pattern = Self.patterns.first { $0.id == patternId }?.pattern ?? .plain

        config = PaperConfig(color: color, pattern: pattern)
        backgroundColor = color
        setNeedsDisplay()
    }

    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // 1. Pattern (lines, dots, grid) — user-selected
        switch config.pattern {
        case .plain: break
        case .lined: drawLines(in: rect, context: context)
        case .dotted: drawDots(in: rect, context: context)
        case .grid: drawGrid(in: rect, context: context)
        }

        // 2. Paper fiber grain — on top of pattern, gives the surface real paper feel
        drawGrain(in: rect, context: context)

        // 3. Soft vignette — darkens edges subtly so paper looks like it's resting on a surface
        drawVignette(in: rect, context: context)
    }

    // MARK: - Patterns
    private func drawLines(in rect: CGRect, context: CGContext) {
        context.setStrokeColor(patternColor.cgColor)
        context.setLineWidth(0.5)
        let spacing = rect.height / linesPerHeight
        var y: CGFloat = spacing
        while y < rect.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            y += spacing
        }
        context.strokePath()
    }

    private func drawDots(in rect: CGRect, context: CGContext) {
        context.setFillColor(patternColor.cgColor)
        let spacing = rect.width / dotsPerWidth
        let dotRadius: CGFloat = spacing * (1.5 / 24)
        let cx = rect.midX
        let cy = rect.midY
        // Deterministic half-count avoids the off-by-one that leaves a one-dot-column gap.
        let halfCount = Int(dotsPerWidth / 2)
        for iy in -halfCount...halfCount {
            for ix in -halfCount...halfCount {
                let x = cx + CGFloat(ix) * spacing
                let y = cy + CGFloat(iy) * spacing
                context.fillEllipse(in: CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
            }
        }
    }

    private func drawGrid(in rect: CGRect, context: CGContext) {
        context.setStrokeColor(patternColor.cgColor)
        context.setLineWidth(0.5)
        let spacing = rect.width / gridCellsPerWidth
        var y: CGFloat = spacing
        while y < rect.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            y += spacing
        }
        var x: CGFloat = spacing
        while x < rect.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
            x += spacing
        }
        context.strokePath()
    }

    // MARK: - Paper Feel
    private func drawGrain(in rect: CGRect, context: CGContext) {
        let isLight = config.color.isLight
        // Two passes: darker specks + lighter specks → gives actual fiber feel, not just noise
        let darkAlpha: CGFloat = isLight ? 0.07 : 0.04
        let lightAlpha: CGFloat = isLight ? 0.05 : 0.09

        srand48(42) // deterministic — grain doesn't flicker on redraw
        let area = rect.width * rect.height
        let count = Int(area * 0.015) // ~1.5 specks per 100pt²

        // Dark specks — varied size for fiber feel
        context.setFillColor(UIColor.black.withAlphaComponent(darkAlpha).cgColor)
        for _ in 0..<count {
            let x = CGFloat(drand48()) * rect.width
            let y = CGFloat(drand48()) * rect.height
            let size = CGFloat(drand48()) * 0.9 + 0.3
            context.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
        }

        // Light specks
        context.setFillColor(UIColor.white.withAlphaComponent(lightAlpha).cgColor)
        for _ in 0..<count {
            let x = CGFloat(drand48()) * rect.width
            let y = CGFloat(drand48()) * rect.height
            let size = CGFloat(drand48()) * 0.9 + 0.3
            context.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
        }
    }

    private func drawVignette(in rect: CGRect, context: CGContext) {
        let isLight = config.color.isLight
        let edgeColor = isLight
            ? UIColor.black.withAlphaComponent(0.12).cgColor
            : UIColor.black.withAlphaComponent(0.25).cgColor
        let centerColor = UIColor.black.withAlphaComponent(0).cgColor

        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [centerColor, centerColor, edgeColor] as CFArray,
            locations: [0.0, 0.55, 1.0]
        ) else { return }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = max(rect.width, rect.height) * 0.75

        context.saveGState()
        context.drawRadialGradient(
            gradient,
            startCenter: center, startRadius: 0,
            endCenter: center, endRadius: radius,
            options: []
        )
        context.restoreGState()
    }
}
