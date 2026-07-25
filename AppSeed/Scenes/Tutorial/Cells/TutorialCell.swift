//
//  TutorialCell.swift
//  AppSeed
//
//  Created by tunay alver on 24.11.2024.
//

import UIKit
import SnapKit

final class TutorialCell: BaseCollectionViewCell {
    // MARK: - UI
    private lazy var cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var gradientView: UIView = {
        let view = UIView()
        let gradient = CAGradientLayer()
        gradient.locations = [0, 0.3, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.addSublayer(gradient)
        view.clipsToBounds = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = ColorText.textPrimary.color
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorText.textSecondary.color
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    // MARK: - Properties
    private var widgetView: FloatingWidgetView?
    private var hasStartedAnimations = false

    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorBackground.backgroundPrimary.color
        draw()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: TutorialCell, _) in
            self.applyGradientColors()
        }
    }

    // MARK: - Configure Cell
    func configure(with model: TutorialUIModel?, index: Int, count: Int) {
        titleLabel.text = model?.title
        subtitleLabel.text = model?.subtitle
        hasStartedAnimations = false
        rebuildWidget(image: model?.image?.image)
        setNeedsLayout()
    }

    private func rebuildWidget(image: UIImage?) {
        widgetView?.stop()
        widgetView?.removeFromSuperview()
        widgetView = nil

        guard let image else { return }
        let widget = FloatingWidgetView(
            image: image,
            cornerRadius: 28,
            rotation: -2 * .pi / 180,
            driftPhase: 0,
            bleedInset: 0
        )
        cardContainer.addSubview(widget)
        widgetView = widget
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let gradient = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = gradientView.bounds
        }
        applyGradientColors()
        layoutWidget()

        if !hasStartedAnimations {
            hasStartedAnimations = true
            startAnimations()
        }
    }

    // FloatingWidgetView animates its own transform — lay it out with manual frame so Auto Layout doesn't fight the transform.
    private func layoutWidget() {
        guard let widget = widgetView else { return }
        let container = cardContainer.bounds
        guard container.width > 0, container.height > 0 else { return }
        let side = min(container.width * 0.62, container.height * 0.9)
        widget.bounds = CGRect(x: 0, y: 0, width: side, height: side)
        widget.center = CGPoint(x: container.midX, y: container.midY)
    }

    private func startAnimations() {
        widgetView?.appear(delay: 0.2) { [weak self] in
            self?.widgetView?.startFloating()
        }
    }

    // iOS pauses CAAnimations on background; resume the floating loop so the card doesn't freeze on return.
    func restartAfterForeground() {
        guard hasStartedAnimations, window != nil else { return }
        widgetView?.startFloating()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        widgetView?.stop()
        widgetView?.removeFromSuperview()
        widgetView = nil
        hasStartedAnimations = false
    }

    // Adaptive gradient from card area to text area — clear→background per UI style.
    private func applyGradientColors() {
        guard let gradient = gradientView.layer.sublayers?.first as? CAGradientLayer else { return }
        let base = ColorBackground.backgroundPrimary.color.resolvedColor(with: traitCollection)
        gradient.colors = [
            base.withAlphaComponent(0.0).cgColor,
            base.withAlphaComponent(0.6).cgColor,
            base.withAlphaComponent(1.0).cgColor
        ]
    }
}

// MARK: - Draw
extension TutorialCell {

    private func draw() {
        addSubview(cardContainer)
        cardContainer.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(12)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-280)
        }

        addSubview(gradientView)
        gradientView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(280)
        }

        // Bottom-up text — subtitle anchored 160pt above cell base, title grows upward; subtitle stays stable across line counts.
        gradientView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-160)
        }

        gradientView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-24)
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-8)
        }
    }
}
