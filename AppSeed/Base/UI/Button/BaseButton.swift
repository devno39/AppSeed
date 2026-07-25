//
//  BaseButton.swift
//  AppSeed
//
//  Created by tunay alver on 10.08.2023.
//

import UIKit

class BaseButton: UIButton {
    // MARK: - Properties
    private var isLoading = false
    private var savedTitle: String?
    private var dotViews: [UIView] = []
    private let dotCount = 3
    private let dotSize: CGFloat = 6
    private let dotSpacing: CGFloat = 6

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.9, y: 0.9) : .identity
                self.alpha = self.isHighlighted ? 0.8 : 1.0
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.4
        }
    }

    var style: Style?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }

    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        prepare()
    }

    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        if style == .circle {
            let radius = min(bounds.width, bounds.height) / 2
            roundCorners(radius: radius, borderColor: style?.borderColor, borderWidth: style?.borderWidth ?? 0)
        } else {
            roundCorners(radius: style?.cornerRadius ?? 12, borderColor: style?.borderColor, borderWidth: style?.borderWidth ?? 0)
        }
    }

    // MARK: - Prepare
    private func prepare() {
        applyStyle()
    }

    func applyStyle() {
        titleLabel?.font = style?.font
        setTitleColor(style?.textColor, for: .normal)

        if let borderColor = style?.borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = style?.borderWidth ?? 0
        }

        backgroundColor = style?.backgroundColor
    }

    // MARK: - Loading
    func showLoading() {
        guard !isLoading else { return }
        isLoading = true
        isUserInteractionEnabled = false
        savedTitle = title(for: .normal)
        setTitle(nil, for: .normal)

        let dotColor = style?.textColor ?? ColorText.textPrimary.color
        let totalWidth = CGFloat(dotCount) * dotSize + CGFloat(dotCount - 1) * dotSpacing
        let startX = (bounds.width - totalWidth) / 2

        for i in 0..<dotCount {
            let dot = UIView()
            dot.backgroundColor = dotColor
            dot.layer.cornerRadius = dotSize / 2
            dot.alpha = 0.3
            dot.frame = CGRect(
                x: startX + CGFloat(i) * (dotSize + dotSpacing),
                y: (bounds.height - dotSize) / 2,
                width: dotSize,
                height: dotSize
            )
            addSubview(dot)
            dotViews.append(dot)

            UIView.animate(
                withDuration: 0.4,
                delay: Double(i) * 0.15,
                options: [.repeat, .autoreverse, .curveEaseInOut]
            ) {
                dot.alpha = 1.0
                dot.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }
        }
    }

    func hideLoading() {
        guard isLoading else { return }
        isLoading = false
        isUserInteractionEnabled = true
        dotViews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()
        setTitle(savedTitle, for: .normal)
    }
}

// MARK: - Style
extension BaseButton {
    enum Style {
        case primary
        case secondary
        case tertiary
        case circle

        var font: UIFont {
            let size: CGFloat
            let weight: UIFont.Weight
            switch self {
            case .primary:
                size = 18; weight = .bold
            case .secondary:
                size = 16; weight = .semibold
            case .tertiary, .circle:
                size = 14; weight = .medium
            }
            if let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: size)
            }
            return .systemFont(ofSize: size, weight: weight)
        }

        var textColor: UIColor {
            switch self {
            case .primary:
                return ColorText.textPrimary.color
            case .secondary:
                return Palette.palette1.color
            case .tertiary:
                return ColorBackground.backgroundSecondary.color
            case .circle:
                return ColorText.textPrimary.color
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .primary:
                return Palette.palette1.color
            case .secondary:
                return ColorBackground.backgroundPrimary.color
            case .tertiary:
                return .clear
            case .circle:
                return ColorBackground.backgroundSecondary.color
            }
        }

        var borderColor: UIColor? {
            switch self {
            case .primary:
                return nil
            case .secondary:
                return Palette.palette1.color
            case .tertiary:
                return nil
            case .circle:
                return ColorBackground.backgroundBorder.color
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .primary:
                return 0
            case .secondary:
                return 1.5
            case .tertiary:
                return 0
            case .circle:
                return 1
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .primary, .secondary:
                return 16
            case .tertiary:
                return 10
            case .circle:
                return 15
            }
        }
    }
}
