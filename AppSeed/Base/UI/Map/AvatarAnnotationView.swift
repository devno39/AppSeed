//
//  AvatarAnnotationView.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit
import MapKit

// The glow lives on its own container: the avatar clips, so the halo can't be its shadow.
final class AvatarAnnotationView: MKAnnotationView {

    // MARK: - Constants
    static let reuseID = "AvatarAnnotationView"
    private let avatarSize: CGFloat = 34
    private let pointerSize: CGFloat = 6
    private let bubbleHeight: CGFloat = 20

    // MARK: - UI
    private lazy var glowContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = avatarSize / 2
        return view
    }()

    private lazy var avatarView: AvatarView = {
        AvatarView(placeholder: .logo_1024, showBorder: false)
    }()

    private lazy var pointerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        view.layer.cornerRadius = pointerSize / 2
        return view
    }()

    private lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = bubbleHeight / 2
        view.layer.borderWidth = 1
        view.setBorderColor(ColorBackground.backgroundBorder.color)
        view.isHidden = true
        return view
    }()

    private lazy var bubbleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 10, fontWeight: .semibold, textColor: ColorText.textPrimary.color)
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
    func configure(with annotation: AvatarAnnotation) {
        avatarView.configure(imageUrl: annotation.imageURL)
        configureBubble(text: annotation.caption)

        let glowColor = annotation.isHighlighted ? Palette.palette3.color : Palette.palette1.color
        glowContainer.layer.shadowPath = UIBezierPath(
            roundedRect: glowContainer.bounds,
            cornerRadius: avatarSize / 2
        ).cgPath
        glowContainer.layer.shadowColor = glowColor.cgColor
        glowContainer.layer.shadowRadius = 16
        glowContainer.layer.shadowOpacity = 0.6
        glowContainer.layer.shadowOffset = .zero

        startBreathingGlow()
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.configure(imageUrl: nil)
        glowContainer.layer.removeAllAnimations()
        glowContainer.layer.shadowOpacity = 0
        configureBubble(text: nil)
    }

    // MARK: - Private
    // The frame grows upward for the caption; centerOffset keeps the pointer on the coordinate.
    private func configureBubble(text: String?) {
        let bubbleSpace = text == nil ? 0 : bubbleHeight + 3
        let totalHeight = avatarSize + pointerSize + 4 + bubbleSpace

        bubbleLabel.text = text
        let bubbleWidth = text == nil ? 0 : bubbleLabel.intrinsicContentSize.width + 16
        let totalWidth = max(avatarSize, bubbleWidth)

        frame = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
        centerOffset = CGPoint(x: 0, y: -totalHeight / 2)

        bubbleView.isHidden = text == nil
        bubbleView.frame = CGRect(x: (totalWidth - bubbleWidth) / 2, y: 0, width: bubbleWidth, height: bubbleHeight)
        bubbleLabel.frame = bubbleView.bounds

        glowContainer.frame = CGRect(
            x: (totalWidth - avatarSize) / 2,
            y: bubbleSpace,
            width: avatarSize,
            height: avatarSize
        )
        avatarView.frame = glowContainer.bounds
        pointerView.frame = CGRect(
            x: (totalWidth - pointerSize) / 2,
            y: bubbleSpace + avatarSize + 2,
            width: pointerSize,
            height: pointerSize
        )
    }

    private func startBreathingGlow() {
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = 0.4
        animation.toValue = 0.8
        animation.duration = 2.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowContainer.layer.add(animation, forKey: "breathingGlow")
    }
}

// MARK: - Draw
extension AvatarAnnotationView {
    private func draw() {
        backgroundColor = .clear

        addSubview(bubbleView)
        bubbleView.addSubview(bubbleLabel)
        addSubview(glowContainer)
        glowContainer.addSubview(avatarView)
        addSubview(pointerView)

        configureBubble(text: nil)
    }
}
