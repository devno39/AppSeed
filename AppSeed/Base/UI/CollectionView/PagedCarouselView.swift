//
//  PagedCarouselView.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit
import SnapKit

final class PagedCarouselView: UIView {

    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        view.contentInsetAdjustmentBehavior = .never
        view.delegate = self
        view.dataSource = self
        view.register(CarouselPageCell.self, forCellWithReuseIdentifier: CarouselPageCell.identifier)
        return view
    }()

    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.currentPageIndicatorTintColor = ColorText.textPrimary.color
        view.pageIndicatorTintColor = ColorText.textPrimary.color.withAlphaComponent(0.3)
        view.isUserInteractionEnabled = false
        view.backgroundStyle = .prominent
        return view
    }()

    // MARK: - Constants
    private let pageControlBottomOffset: CGFloat = 6

    // MARK: - Closure
    var onPageChanged: AnyClosure<Int>?
    var onPageTapped: AnyClosure<Int>?

    // MARK: - Properties
    private(set) var currentPage: Int = 0
    private var pageCount: Int = 0
    private var pageProvider: ((Int) -> UIView)?
    private var pageViews: [Int: UIView] = [:]
    private var lastLaidOutSize: CGSize = .zero

    // MARK: - Init
    init(showsPageControl: Bool = true) {
        super.init(frame: .zero)
        pageControl.isHidden = !showsPageControl
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    // Re-snapping on every layout pass would cancel an in-flight drag.
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != lastLaidOutSize else { return }
        lastLaidOutSize = bounds.size
        collectionView.collectionViewLayout.invalidateLayout()
        scrollToPage(currentPage, animated: false)
    }

    // MARK: - Configure
    func configure(pageCount: Int, initialPage: Int = 0, pageProvider: @escaping (Int) -> UIView) {
        self.pageCount = pageCount
        self.pageProvider = pageProvider
        pageViews = [:]
        currentPage = max(0, min(initialPage, pageCount - 1))

        pageControl.numberOfPages = pageCount
        pageControl.currentPage = currentPage
        collectionView.reloadData()
        scrollToPage(currentPage, animated: false)
    }

    func clear() {
        pageCount = 0
        pageProvider = nil
        pageViews = [:]
        pageControl.numberOfPages = 0
        collectionView.reloadData()
    }

    func view(atPage index: Int) -> UIView? {
        pageViews[index]
    }

    func scrollToPage(_ index: Int, animated: Bool) {
        guard pageCount > 0, collectionView.bounds.width > 0 else { return }
        let clamped = max(0, min(index, pageCount - 1))
        let offset = CGPoint(x: collectionView.bounds.width * CGFloat(clamped), y: 0)
        collectionView.setContentOffset(offset, animated: animated)
    }

    // MARK: - Private
    private func pageView(at index: Int) -> UIView? {
        if let cached = pageViews[index] { return cached }
        guard let created = pageProvider?(index) else { return nil }
        pageViews[index] = created
        return created
    }

    private func page(for scrollView: UIScrollView) -> Int? {
        guard pageCount > 0, scrollView.bounds.width > 0 else { return nil }
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        return max(0, min(page, pageCount - 1))
    }

    private func finalizePageChange(scrollView: UIScrollView) {
        guard let page = page(for: scrollView), page != currentPage else { return }
        currentPage = page
        onPageChanged?(page)
    }
}

// MARK: - UICollectionViewDataSource
extension PagedCarouselView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CarouselPageCell.identifier,
            for: indexPath
        ) as? CarouselPageCell else {
            return UICollectionViewCell()
        }
        if let pageView = pageView(at: indexPath.item) {
            cell.configure(pageView: pageView)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PagedCarouselView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onPageTapped?(indexPath.item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let page = page(for: scrollView) else { return }
        pageControl.currentPage = page
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        finalizePageChange(scrollView: scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        finalizePageChange(scrollView: scrollView)
    }
}

// MARK: - PaletteUpdatable
extension PagedCarouselView: PaletteUpdatable {
    func updatePaletteColors() {
        pageControl.currentPageIndicatorTintColor = ColorText.textPrimary.color
        pageControl.pageIndicatorTintColor = ColorText.textPrimary.color.withAlphaComponent(0.3)
    }
}

// MARK: - Draw
extension PagedCarouselView {
    private func draw() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.centerX.equalTo(collectionView)
            $0.bottom.equalTo(collectionView).offset(-pageControlBottomOffset)
        }
    }
}
