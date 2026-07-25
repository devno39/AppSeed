//
//  PaywallFeatureRow.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

final class PaywallFeatureRow: UIView {

    // MARK: - UI
    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = Palette.palette1.color
        return iv
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 15, fontWeight: .semibold, textColor: ColorText.textPrimary.color)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var subtitleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 13, fontWeight: .regular, textColor: ColorText.textSecondary.color)
        label.numberOfLines = 2
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()

    // MARK: - Init
    init(icon: String, title: String, subtitle: String) {
        super.init(frame: .zero)

        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        titleLabel.text = title
        subtitleLabel.text = subtitle

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        addSubview(iconView)
        addSubview(textStack)

        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(2)
            $0.width.height.equalTo(24)
        }

        textStack.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.top.bottom.equalToSuperview()
        }
    }
}
