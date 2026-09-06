//
//  WhatsNewView.swift
//  AppSeed
//
//  Created by Claude on 16.08.2026.
//

import UIKit
import SnapKit

// Drops into a BottomSheet as its customView: a list of what the update brought, one emoji
// bullet per line.
final class WhatsNewView: UIView {

    // MARK: - Constants
    private let bulletSize: CGFloat = 34
    private let rowSpacing: CGFloat = 14

    // MARK: - UI
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = rowSpacing
        stack.alignment = .fill
        return stack
    }()

    // MARK: - Init
    init(items: [WhatsNewItem]) {
        super.init(frame: .zero)
        setup(items: items)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup(items: [WhatsNewItem]) {
        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }

        items.forEach { stackView.addArrangedSubview(row(for: $0)) }
    }

    // MARK: - Private
    private func row(for item: WhatsNewItem) -> UIView {
        let bullet = UILabel()
        bullet.text = item.emoji
        bullet.font = .systemFont(ofSize: 17)
        bullet.textAlignment = .center
        bullet.backgroundColor = Palette.palette1.color.withAlphaComponent(0.14)
        bullet.layer.cornerRadius = bulletSize / 2
        bullet.clipsToBounds = true
        bullet.setContentHuggingPriority(.required, for: .horizontal)
        bullet.snp.makeConstraints { $0.size.equalTo(bulletSize) }

        let label = UILabel()
        label.text = item.text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = ColorText.textPrimary.color
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [bullet, label])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return row
    }
}
