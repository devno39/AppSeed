//
//  BaseSectionHeaderView.swift
//  AppSeed
//
//  Created by Claude on 27.03.2026.
//

import UIKit
import SnapKit

final class BaseSectionHeaderView: UITableViewHeaderFooterView, ReusableView {

    // MARK: - UI
    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 15, fontWeight: .bold, textColor: ColorText.textSecondary.color)
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = ColorText.textSecondary.color
        button.isHidden = true
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Closure
    var onAction: EmptyClosure?

    // MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Prepare
    override func prepareForReuse() {
        super.prepareForReuse()
        onAction = nil
        actionButton.isHidden = true
    }

    // MARK: - Configure
    func configure(title: String) {
        titleLabel.text = title
    }

    func configure(title: String, actionIcon: String) {
        titleLabel.text = title
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        actionButton.setImage(UIImage(systemName: actionIcon, withConfiguration: config), for: .normal)
        actionButton.isHidden = false
    }

    // MARK: - Actions
    @objc private func actionTapped() {
        onAction?()
    }
}

// MARK: - Draw
extension BaseSectionHeaderView {
    private func draw() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(actionButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
            $0.bottom.equalToSuperview().offset(-6)
        }

        actionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
        }
    }
}
