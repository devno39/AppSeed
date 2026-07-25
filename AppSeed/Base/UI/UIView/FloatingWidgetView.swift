//
//  FloatingWidgetView.swift
//  AppSeed
//
//  Created by tunay alver on 14.05.2026.
//

import UIKit
import SnapKit

final class FloatingWidgetView: UIView {

    // MARK: - UI
    // Outer layer carries shadow (no clip); inner clipView clips an oversized imageView so the asset bleeds past the rounded rect.
    private lazy var clipView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerCurve = .continuous
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    // MARK: - Properties
    private let baseRotation: CGFloat
    private let driftPhase: Double

    // MARK: - Init
    init(image: UIImage, cornerRadius: CGFloat, rotation: CGFloat, driftPhase: Double, bleedInset: CGFloat) {
        self.baseRotation = rotation
        self.driftPhase = driftPhase
        super.init(frame: .zero)
        backgroundColor = .clear

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 12)

        addSubview(clipView)
        clipView.snp.makeConstraints { $0.edges.equalToSuperview() }
        clipView.layer.cornerRadius = cornerRadius

        clipView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(-bleedInset)
        }
        imageView.image = image

        transform = CGAffineTransform(rotationAngle: baseRotation)
        alpha = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Entry
    func appear(delay: TimeInterval, onCompletion: (() -> Void)? = nil) {
        let initial = CGAffineTransform(rotationAngle: baseRotation)
            .scaledBy(x: 0.88, y: 0.88)
            .translatedBy(x: 0, y: 24)
        transform = initial

        UIView.animate(
            withDuration: 0.7,
            delay: delay,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.3,
            options: [.allowUserInteraction]
        ) { [weak self] in
            guard let self else { return }
            self.alpha = 1
            self.transform = CGAffineTransform(rotationAngle: self.baseRotation)
        } completion: { _ in
            onCompletion?()
        }
    }

    // MARK: - Idle floating
    // Minimal motion — gentle vertical hover + shadow breath.
    func startFloating() {
        let phaseOffset = driftPhase * 2.0

        // Y bobbing — soft vertical hover
        let bob = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bob.values = [0, -4, 0, 3, 0]
        bob.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        bob.duration = 4.2
        bob.beginTime = CACurrentMediaTime() + phaseOffset
        bob.repeatCount = .infinity
        bob.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(bob, forKey: "bob")

        // Shadow glow — subtle depth breath
        let glow = CAKeyframeAnimation(keyPath: "shadowOpacity")
        glow.values = [0.30, 0.42, 0.32, 0.40, 0.30]
        glow.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        glow.duration = 3.4
        glow.beginTime = CACurrentMediaTime() + phaseOffset * 0.6
        glow.repeatCount = .infinity
        layer.add(glow, forKey: "glow")
    }

    // MARK: - Cleanup
    func stop() {
        layer.removeAllAnimations()
    }
}
