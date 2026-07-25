//
//  RingProgressView.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// Circular progress ring: a full-circle track under a stroked arc that fills clockwise
// from 12 o'clock. Radius auto-derives from bounds, so the same view rings any badge size.
final class RingProgressView: UIView, PaletteUpdatable {

    // MARK: - Constants
    private static let startAngle: CGFloat = -.pi / 2
    private static let endAngle: CGFloat = .pi * 1.5

    // MARK: - UI
    private lazy var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = trackColor.cgColor
        layer.lineWidth = lineWidth
        return layer
    }()

    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = ringColor.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = .round
        layer.strokeEnd = 0
        return layer
    }()

    // MARK: - Properties
    var lineWidth: CGFloat = 2.5 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }

    // Palette-driven by default — refreshed by the BaseViewController palette walk.
    var ringColor: UIColor = Palette.palette1.color {
        didSet { progressLayer.strokeColor = ringColor.cgColor }
    }

    var trackColor: UIColor = Palette.palette1.color.withAlphaComponent(0.15) {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }

    private(set) var progress: CGFloat = 0

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        trackLayer.frame = bounds
        progressLayer.frame = bounds
        let path = ringPath().cgPath
        trackLayer.path = path
        progressLayer.path = path
    }

    // MARK: - Public
    func setProgress(_ progress: CGFloat, animated: Bool) {
        let clamped = max(0, min(1, progress))
        self.progress = clamped
        if animated {
            progressLayer.strokeEnd = clamped
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressLayer.strokeEnd = clamped
            CATransaction.commit()
        }
    }

    // Reuse-friendly: snap back to empty with no animation.
    func reset() {
        progress = 0
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = 0
        CATransaction.commit()
    }

    // MARK: - PaletteUpdatable
    @objc dynamic func updatePaletteColors() {
        ringColor = Palette.palette1.color
        trackColor = Palette.palette1.color.withAlphaComponent(0.15)
    }

    // MARK: - Private
    private func ringPath() -> UIBezierPath {
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        return UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: max(0, radius),
            startAngle: Self.startAngle,
            endAngle: Self.endAngle,
            clockwise: true
        )
    }
}
