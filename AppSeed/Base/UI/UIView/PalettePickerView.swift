//
//  PalettePickerView.swift
//  AppSeed
//
//  Created by Claude on 13.03.2026.
//

import UIKit
import SnapKit

final class PalettePickerView: UIView {

    // MARK: - Constants
    private let circleSize: CGFloat = 44
    private let ringSize: CGFloat = 52
    private let spacing: CGFloat = 12

    // MARK: - UI
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = spacing
        stack.alignment = .center
        stack.distribution = .equalCentering
        return stack
    }()

    // MARK: - Properties
    private var circleViews: [PaletteCircleView] = []
    private var customCircle: PaletteCustomCircleView?
    var onSelect: ((PalettePreset) -> Void)?
    var onCustomTap: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-12)
        }

        let current = PaletteManager.shared.currentPreset

        for preset in PalettePreset.allPresets {
            let circle = PaletteCircleView(
                preset: preset,
                size: circleSize,
                ringSize: ringSize,
                isSelected: preset == current
            )
            circle.onTap = { [weak self] tapped in
                self?.selectPreset(tapped)
            }
            stackView.addArrangedSubview(circle)
            circleViews.append(circle)
        }

        // Custom color circle
        let custom = PaletteCustomCircleView(size: circleSize, ringSize: ringSize, isSelected: current == .custom)
        custom.onTap = { [weak self] in
            self?.onCustomTap?()
        }
        stackView.addArrangedSubview(custom)
        customCircle = custom
    }

    // MARK: - Selection
    private func selectPreset(_ preset: PalettePreset) {
        circleViews.forEach { $0.setSelected($0.preset == preset) }
        customCircle?.setSelected(false)
        onSelect?(preset)
    }

    func selectCustom() {
        circleViews.forEach { $0.setSelected(false) }
        customCircle?.setSelected(true)
        customCircle?.refreshColor()
    }
}

// MARK: - PaletteCircleView
private final class PaletteCircleView: UIView {

    // MARK: - Properties
    let preset: PalettePreset
    var onTap: ((PalettePreset) -> Void)?
    private let circleSize: CGFloat
    private let ringSize: CGFloat

    // MARK: - UI
    private lazy var ringView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = ringSize / 2
        view.layer.borderWidth = 2.5
        view.setBorderColor(UIColor(rgb: preset.colors.primary))
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(rgb: preset.colors.primary).cgColor,
            UIColor(rgb: preset.colors.tertiary).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private lazy var colorCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = circleSize / 2
        view.clipsToBounds = true
        view.layer.addSublayer(gradientLayer)
        return view
    }()

    private lazy var checkView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        let view = UIImageView(image: UIImage(systemName: Symbols.checkmark.symbolName, withConfiguration: config))
        view.tintColor = .white
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    // MARK: - Init
    init(preset: PalettePreset, size: CGFloat, ringSize: CGFloat, isSelected: Bool) {
        self.preset = preset
        self.circleSize = size
        self.ringSize = ringSize
        super.init(frame: .zero)
        setup()
        setSelected(isSelected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = colorCircle.bounds
    }

    // MARK: - Setup
    private func setup() {
        addSubview(ringView)
        addSubview(colorCircle)
        colorCircle.addSubview(checkView)

        snp.makeConstraints {
            $0.width.height.equalTo(ringSize)
        }

        ringView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        colorCircle.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(circleSize)
        }

        checkView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    // MARK: - Selection
    func setSelected(_ selected: Bool) {
        ringView.isHidden = !selected
        checkView.isHidden = !selected

        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.transform = selected ? CGAffineTransform(scaleX: 1.08, y: 1.08) : .identity
        }
    }

    @objc private func tapped() {
        onTap?(preset)
    }
}

// MARK: - PaletteCustomCircleView
private final class PaletteCustomCircleView: UIView {

    // MARK: - Properties
    var onTap: (() -> Void)?
    private let circleSize: CGFloat
    private let ringSize: CGFloat

    // MARK: - UI
    private lazy var ringView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = ringSize / 2
        view.layer.borderWidth = 2.5
        view.setBorderColor(Palette.palette1.color)
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    private lazy var colorCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = circleSize / 2
        view.backgroundColor = ColorBackground.backgroundTertiary.color
        view.layer.borderWidth = 1
        view.setBorderColor(ColorBackground.backgroundBorder.color)
        return view
    }()

    private lazy var plusIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let view = UIImageView(image: UIImage(systemName: Symbols.plus.symbolName, withConfiguration: config))
        view.tintColor = ColorText.textSecondary.color
        view.contentMode = .scaleAspectFit
        return view
    }()

    // MARK: - Init
    init(size: CGFloat, ringSize: CGFloat, isSelected: Bool) {
        self.circleSize = size
        self.ringSize = ringSize
        super.init(frame: .zero)
        setup()
        if isSelected { refreshColor() }
        setSelected(isSelected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        addSubview(ringView)
        addSubview(colorCircle)
        colorCircle.addSubview(plusIcon)

        snp.makeConstraints {
            $0.width.height.equalTo(ringSize)
        }

        ringView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        colorCircle.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(circleSize)
        }

        plusIcon.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    // MARK: - Selection
    func setSelected(_ selected: Bool) {
        ringView.isHidden = !selected
        plusIcon.tintColor = selected ? .white : ColorText.textSecondary.color

        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.transform = selected ? CGAffineTransform(scaleX: 1.08, y: 1.08) : .identity
        }
    }

    func refreshColor() {
        let color = Palette.palette1.color
        colorCircle.backgroundColor = color
        colorCircle.layer.borderWidth = 0
        ringView.setBorderColor(color)
    }

    @objc private func tapped() {
        onTap?()
    }
}
