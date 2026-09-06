//
//  LabelPinAnnotationView.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit
import MapKit

final class LabelPinAnnotationView: MKAnnotationView {

    // MARK: - Constants
    static let reuseID = "LabelPinAnnotationView"
    private let chipHeight: CGFloat = 28
    private let horizontalPadding: CGFloat = 10
    private let pointerSize: CGFloat = 8
    private let pointerGap: CGFloat = 4

    // MARK: - UI
    private lazy var chipView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = chipHeight / 2
        view.layer.borderWidth = 1
        view.setBorderColor(ColorBackground.backgroundBorder.color)
        return view
    }()

    private lazy var pointerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        view.layer.cornerRadius = pointerSize / 2
        return view
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 12, fontWeight: .semibold, textColor: ColorText.textPrimary.color)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        draw()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(with annotation: LabelPinAnnotation) {
        titleLabel.text = annotation.text

        let width = titleLabel.intrinsicContentSize.width + horizontalPadding * 2
        let height = chipHeight + pointerGap + pointerSize
        frame = CGRect(x: 0, y: 0, width: width, height: height)

        // The dot lands on the coordinate; the chip hangs above it.
        let dotCenterY = chipHeight + pointerGap + pointerSize / 2
        centerOffset = CGPoint(x: 0, y: height / 2 - dotCenterY)

        chipView.frame = CGRect(x: 0, y: 0, width: width, height: chipHeight)
        titleLabel.frame = chipView.bounds.insetBy(dx: horizontalPadding, dy: 0)
        pointerView.frame = CGRect(
            x: width / 2 - pointerSize / 2,
            y: chipHeight + pointerGap,
            width: pointerSize,
            height: pointerSize
        )
        chipView.layer.shadowPath = UIBezierPath(
            roundedRect: chipView.bounds,
            cornerRadius: chipHeight / 2
        ).cgPath
    }

    // MARK: - Actions
    func animateTap() {
        UIView.animate(
            withDuration: 0.12,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: .curveEaseInOut
        ) {
            self.chipView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6) {
                self.chipView.transform = .identity
            }
        }
    }
}

// MARK: - Draw
extension LabelPinAnnotationView {
    private func draw() {
        backgroundColor = .clear
        displayPriority = .required

        addSubview(chipView)
        chipView.addSubview(titleLabel)
        addSubview(pointerView)
        chipView.drawShadow(radius: 12, opacity: 0.4)
    }
}
