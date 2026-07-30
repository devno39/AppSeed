//
//  CarouselPageCell.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit
import SnapKit

final class CarouselPageCell: BaseCollectionViewCell {

    // MARK: - Properties
    private weak var pageView: UIView?

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    // MARK: - Configure
    func configure(pageView: UIView) {
        guard pageView !== self.pageView else { return }
        detachPageView()

        pageView.removeFromSuperview()
        contentView.addSubview(pageView)
        pageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        self.pageView = pageView
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        detachPageView()
    }

    // MARK: - Private
    // A page view may already have moved to another cell — removing its constraints strips that cell.
    private func detachPageView() {
        defer { pageView = nil }
        guard let pageView, pageView.superview === contentView else { return }
        pageView.snp.removeConstraints()
        pageView.removeFromSuperview()
    }
}
