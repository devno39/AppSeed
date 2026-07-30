//
//  TutorialViewController.swift
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
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    private lazy var glassActionView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.clipsToBounds = true
        return view
    }()

    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.currentPageIndicatorTintColor = Palette.palette1.color
        view.pageIndicatorTintColor = ColorText.textSecondary.color.withAlphaComponent(0.3)
        view.currentPage = 0
        view.numberOfPages = viewModel?.models.count ?? 0
        return view
    }()

    private lazy var actionButton: BaseButton = {
        let button = BaseButton(style: .primary)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // iOS pauses CAAnimations on background; resume the visible page's loop so the card doesn't freeze on return.
    @objc private func handleDidBecomeActive() {
        guard isViewLoaded, view.window != nil else { return }
        collectionView.visibleCells.forEach {
            ($0 as? TutorialCell)?.restartAfterForeground()
        }
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        draw()
        prepareCollectionView()
    }

    // MARK: - Localization
    override func configureLocalization() {
        updateActionButtonTitle()
    }

    private func prepareCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TutorialCell.self)
        collectionView.backgroundColor = ColorBackground.backgroundPrimary.color
    }

    // MARK: - Action
    @objc private func actionButtonTapped() {
        let lastPage = (viewModel?.numberOfItems() ?? 0) - 1
        if pageControl.currentPage == lastPage {
            UserDefaultsWrapper.tutorials_seen = true
            UserDefaults.standard.forceSave()
            // Replay from Profile presents modally; first run swaps the window root.
            if presentingViewController != nil {
                dismiss(animated: true)
            } else {
                router?.showLogin()
            }
        } else {
            let nextIndex = min(pageControl.currentPage + 1, lastPage)
            let indexPath = IndexPath(item: nextIndex, section: 0)
            guard collectionView.isValid(indexPath: indexPath) else { return }
            pageControl.currentPage = nextIndex
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            updateActionButtonTitle()
        }
    }

    private func updateActionButtonTitle() {
        let lastPage = (viewModel?.numberOfItems() ?? 0) - 1
        let title = pageControl.currentPage == lastPage
            ? TutorialLocalizable.actionButton_title_end
            : TutorialLocalizable.actionButton_title
        actionButton.setTitle(title, for: .normal)
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
        cell.configure(with: tutorial, index: indexPath.row, count: viewModel?.numberOfItems() ?? 1)
        return cell
    }
}

// MARK: - UIScrollView Delegate
extension TutorialViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(round(x / view.frame.width))
        updateActionButtonTitle()
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
extension TutorialViewController {

    private func draw() {
        // Collection view (full screen)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Glass action view (bottom)
        view.addSubview(glassActionView)
        glassActionView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(140)
        }

        // Page control in glass view
        glassActionView.contentView.addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
        }

        // Action button in glass view
        glassActionView.contentView.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
            $0.top.equalTo(pageControl.snp.bottom).offset(16)
            $0.bottom.lessThanOrEqualTo(glassActionView.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
}
