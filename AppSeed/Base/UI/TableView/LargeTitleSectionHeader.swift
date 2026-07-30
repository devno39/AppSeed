//
//  LargeTitleSectionHeader.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import SnapKit

// A large-title section header: a bold title over a lighter subtitle line.
final class LargeTitleSectionHeader: UITableViewHeaderFooterView, ReusableView {

    // MARK: - UI
    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 28, fontWeight: .bold, textColor: .label)
        return label
    }()

    private lazy var subtitleLabel: BaseLabel = {
        let label = BaseLabel(fontSize: 16, fontWeight: .medium, textColor: .secondaryLabel)
        return label
    }()

    // MARK: - Init
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    // MARK: - Private
    func subtitleFrame(in view: UIView) -> CGRect {
        subtitleLabel.convert(subtitleLabel.bounds, to: view)
    }
}

// MARK: - Draw
extension LargeTitleSectionHeader {
    private func draw() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.left.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
