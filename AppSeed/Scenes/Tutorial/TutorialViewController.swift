//
//  ViewControllerTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit
import SnapKit

final class TutorialViewController: BaseViewController<TutorialViewModel, TutorialRouter> {
    // MARK: - UI
    private lazy var collectionView: BaseCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = BaseCollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        return view
    }()
    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.currentPageIndicatorTintColor = Palette.palette1.color
        view.pageIndicatorTintColor = ColorBackground.backgroundSecondary.color
        view.currentPage = 0
        view.numberOfPages = viewModel?.models.count ?? 0
        return view
    }()
    private lazy var actionView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        return view
    }()
    private lazy var actionButton: BaseButton = {
        let button = BaseButton(style: .primary)
        button.setTitle(TutorialLocalizable.actionButton_title, for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        draw()
        prepareCollectionView()
    }
    
    private func prepareCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TutorialCell.self)
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
    }
    
    // MARK: - Action
    @objc private func actionButtonTapped() {
        let lastPage = (viewModel?.numberOfItems() ?? 0) - 1
        if pageControl.currentPage == lastPage {
            debugPrint("LAST PAGE ACTION")
        } else {
            let nextIndex = min(pageControl.currentPage + 1, lastPage)
            let indexPath = IndexPath(item: nextIndex, section: 0)
            guard collectionView.isValid(indexPath: indexPath) else { return }
            pageControl.currentPage = nextIndex
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

// MARK: - CollectionView DataSource & Delegate
extension TutorialViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.numberOfItems() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tutorial = viewModel?.getTutorial(indexPath.row)
        let cell: TutorialCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: tutorial)
        return cell
    }
}

// MARK: - UIScrollView Delegate
extension TutorialViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(round(x / view.frame.width))
    }
}

// MARK: - CollectionView UICollectionViewDelegateFlowLayout
extension TutorialViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: .zero, left: .zero, bottom: .zero, right: .zero)
    }
}

// MARK: - Draw
private extension TutorialViewController {
    private func draw() {
        view.addSubview(actionView)
        actionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        actionView.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalTo(actionView.safeAreaLayoutGuide.snp.bottom)
        }
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(16)
            $0.bottom.equalTo(actionView.snp.top).offset(-8)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(pageControl.snp.top).offset(-8)
        }
    }
}
