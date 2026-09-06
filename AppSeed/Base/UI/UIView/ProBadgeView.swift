//
//  ProBadgeView.swift
//  AppSeed
//
//  Created by Claude on 31.07.2026.
//

import UIKit
import SnapKit

final class ProBadgeView: UIView, PaletteUpdatable {

    // MARK: - UI
    private lazy var crownView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = Palette.palette1.color
        let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .heavy)
        view.image = UIImage(systemName: Symbols.crown.symbolName, withConfiguration: config)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .heavy)
        label.textColor = Palette.palette1.color
        label.text = Localizable.pro
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [crownView, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 3
        stack.alignment = .center
        return stack
    }()

    // MARK: - Properties
    // Full-bleed hosts (a map, a photo) need a plate behind the stamp; a card already on a panel does not.
    private let filled: Bool

    // MARK: - Closure
    var onTap: EmptyClosure? {
        didSet {
            isUserInteractionEnabled = onTap != nil
            if onTap != nil, tapGesture.view == nil {
                addGestureRecognizer(tapGesture)
            }
        }
    }

    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))

    // MARK: - Init
    init(filled: Bool) {
        self.filled = filled
        super.init(frame: .zero)
        draw()
        prepare()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Prepare
    private func prepare() {
        isUserInteractionEnabled = false
        layer.borderWidth = 2
        setBorderColor(Palette.palette1.color)
        layer.cornerRadius = 5
        transform = CGAffineTransform(rotationAngle: -.pi / 10)
        if filled {
            backgroundColor = ColorBackground.backgroundSecondary.color
        }
    }

    // The stamp is ~46x24 — a tappable one still needs a ~44pt hit target.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard onTap != nil else { return super.point(inside: point, with: event) }
        let dx = min(0, (bounds.width - 44) / 2)
        let dy = min(0, (bounds.height - 44) / 2)
        return bounds.insetBy(dx: dx, dy: dy).contains(point)
    }

    // MARK: - Actions
    @objc private func handleTap() {
        onTap?()
    }

    // MARK: - PaletteUpdatable
    @objc dynamic func updatePaletteColors() {
        crownView.tintColor = Palette.palette1.color
        titleLabel.textColor = Palette.palette1.color
        setBorderColor(Palette.palette1.color)
        if filled {
            backgroundColor = ColorBackground.backgroundSecondary.color
        }
    }
}

// MARK: - Draw
extension ProBadgeView {
    private func draw() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-5)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
    }
}
