//
//  StatusBubbleView.swift
//  AppSeed
//
//  Created by Claude on 30.06.2026.
//

import UIKit
import SnapKit

// Pill body + a tail pointing at tailAnchor's center, drawn as one continuous path.
final class StatusBubbleView: UIView {

    // MARK: - UI
    let contentView = UIView()

    // MARK: - Constants
    static let tailHeight: CGFloat = 6
    static let tailWidth: CGFloat = 12

    // MARK: - Properties
    weak var tailAnchor: UIView?          // the tail points at this view's horizontal center
    var isHighlighted = false { didSet { updateColors() } }
    private let tailOnTop: Bool
    private let shape = CAShapeLayer()

    // MARK: - Init
    init(tailOnTop: Bool = false) {
        self.tailOnTop = tailOnTop
        super.init(frame: .zero)
        layer.addSublayer(shape)
        updateColors()

        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(tailOnTop ? Self.tailHeight : 0)
            $0.bottom.equalToSuperview().offset(tailOnTop ? 0 : -Self.tailHeight)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        shape.frame = bounds
        shape.path = bubblePath().cgPath
    }

    // MARK: - Configure
    func updateColors() {
        shape.fillColor = ColorBackground.backgroundTertiary.color.cgColor
        shape.strokeColor = isHighlighted
            ? Palette.palette1.color.cgColor
            : ColorBackground.backgroundBorder.color.cgColor
        shape.lineWidth = isHighlighted ? 1 : 0.5
    }

    // MARK: - Private
    private func bubblePath() -> UIBezierPath {
        let w = bounds.width
        let bodyH = bounds.height - Self.tailHeight
        let r = bodyH / 2
        let bodyTop: CGFloat = tailOnTop ? Self.tailHeight : 0
        let bodyBottom = bodyTop + bodyH

        // Tail x = the anchor's center mapped into this view, clamped to the straight edge.
        let anchorX = tailAnchor.map { $0.convert(CGPoint(x: $0.bounds.midX, y: 0), to: self).x } ?? w / 2
        let cx = min(max(anchorX, r + Self.tailWidth / 2), w - r - Self.tailWidth / 2)

        let path = UIBezierPath()
        if tailOnTop {
            path.move(to: CGPoint(x: r, y: bodyTop))
            path.addLine(to: CGPoint(x: cx - Self.tailWidth / 2, y: bodyTop))
            path.addLine(to: CGPoint(x: cx, y: 0))
            path.addLine(to: CGPoint(x: cx + Self.tailWidth / 2, y: bodyTop))
            path.addLine(to: CGPoint(x: w - r, y: bodyTop))
            path.addArc(withCenter: CGPoint(x: w - r, y: bodyTop + r), radius: r, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
            path.addLine(to: CGPoint(x: r, y: bodyBottom))
            path.addArc(withCenter: CGPoint(x: r, y: bodyTop + r), radius: r, startAngle: .pi / 2, endAngle: .pi * 3 / 2, clockwise: true)
        } else {
            path.move(to: CGPoint(x: r, y: 0))
            path.addLine(to: CGPoint(x: w - r, y: 0))
            path.addArc(withCenter: CGPoint(x: w - r, y: r), radius: r, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
            path.addLine(to: CGPoint(x: cx + Self.tailWidth / 2, y: bodyBottom))
            path.addLine(to: CGPoint(x: cx, y: bounds.height))
            path.addLine(to: CGPoint(x: cx - Self.tailWidth / 2, y: bodyBottom))
            path.addLine(to: CGPoint(x: r, y: bodyBottom))
            path.addArc(withCenter: CGPoint(x: r, y: r), radius: r, startAngle: .pi / 2, endAngle: .pi * 3 / 2, clockwise: true)
        }
        path.close()
        return path
    }
}
