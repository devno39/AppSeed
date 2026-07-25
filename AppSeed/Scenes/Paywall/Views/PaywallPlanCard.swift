//
//  PaywallPlanCard.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

final class PaywallPlanCard: UIView {

    // MARK: - UI
    private lazy var badgeLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 12, fontWeight: .bold, textColor: Palette.palette1.color)
        label.textAlignment = .center
        label.backgroundColor = ColorBackground.backgroundPrimary.color
        label.layer.cornerRadius = 11
        label.clipsToBounds = true
        label.layer.borderWidth = 2.5
        label.layer.borderColor = Palette.palette1.color.cgColor
        label.isHidden = true
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 12, fontWeight: .medium, textColor: ColorText.textSecondary.color)
        label.textAlignment = .center
        return label
    }()

    private lazy var priceLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 20, fontWeight: .bold, textColor: ColorText.textPrimary.color)
        label.textAlignment = .center
        return label
    }()

    private lazy var periodLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 11, fontWeight: .regular, textColor: ColorText.textSecondary.color)
        label.textAlignment = .center
        return label
    }()

    private lazy var cardBackground: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 2
        view.layer.borderColor = ColorBackground.backgroundBorder.color.cgColor
        return view
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, priceLabel, periodLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()

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
        clipsToBounds = false
        backgroundColor = .clear

        addSubview(cardBackground)
        addSubview(contentStack)
        addSubview(badgeLabel)

        cardBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        badgeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(snp.top)
            $0.height.equalTo(24)
            $0.width.greaterThanOrEqualTo(74)
            $0.width.lessThanOrEqualTo(self).offset(-8)
        }
    }

    // MARK: - Configure
    func configure(title: String, price: String, period: String, badge: String?) {
        titleLabel.text = title
        priceLabel.text = price
        periodLabel.text = period

        if let badge, !badge.isEmpty {
            badgeLabel.text = "  \(badge)  "
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
    }

    // MARK: - Selection
    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.cardBackground.layer.borderColor = selected
                ? Palette.palette1.color.cgColor
                : ColorBackground.backgroundBorder.color.cgColor
            self.cardBackground.layer.borderWidth = selected ? 2.5 : 2
            self.transform = selected
                ? CGAffineTransform(scaleX: 1.03, y: 1.03)
                : .identity
        }
    }
}
