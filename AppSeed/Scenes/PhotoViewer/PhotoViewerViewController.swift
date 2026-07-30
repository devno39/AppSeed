//
//  PhotoViewerViewController.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import UIKit
import SnapKit

final class PhotoViewerViewController: BaseViewController<PhotoViewerViewModel, PhotoViewerRouter> {

    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never
        view.delegate = self
        view.dataSource = self
        view.register(PhotoViewerCell.self, forCellWithReuseIdentifier: PhotoViewerCell.identifier)
        return view
    }()

    private lazy var infoView: PhotoViewerInfoView = {
        PhotoViewerInfoView()
    }()

    // MARK: - Constants
    private let dismissTranslation: CGFloat = 120
    private let dismissVelocity: CGFloat = 800

    // MARK: - Properties
    private var currentIndex = 0
    private var isUIVisible = true
    private var hasLaidOut = false

    private var isZoomed: Bool {
        guard let cell = collectionView.visibleCells.first as? PhotoViewerCell else { return false }
        return cell.isZoomed
    }

    // Strong ref — the delegate has to outlive the present leg to animate the dismiss.
    var transitionDelegate: ZoomTransitionDelegate?

    // MARK: - Life Cycle
    override var prefersStatusBarHidden: Bool { true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasLaidOut, collectionView.bounds.width > 0 else { return }
        hasLaidOut = true
        collectionView.collectionViewLayout.invalidateLayout()
        if currentIndex > 0 {
            collectionView.contentOffset.x = CGFloat(currentIndex) * collectionView.bounds.width
        }
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        view.backgroundColor = .black
        navigationController?.view.backgroundColor = .clear
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true

        currentIndex = viewModel?.startIndex ?? 0
        draw()
        setupNavBar()
        updateCounter()
        configureInfo()
        setupPanGesture()
    }

    // MARK: - Navigation
    private func setupNavBar() {
        navigationItem.hidesBackButton = true

        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let backImage = UIImage(systemName: Symbols.chevron_left.symbolName, withConfiguration: config)
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backTapped))
        backButton.tintColor = ColorText.textPrimary.color
        navigationItem.leftBarButtonItem = backButton

        guard viewModel?.actions.isNotEmpty == true else { return }
        let moreImage = UIImage(systemName: Symbols.ellipsis.symbolName, withConfiguration: config)
        let moreButton = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(optionsTapped))
        moreButton.tintColor = ColorText.textPrimary.color
        navigationItem.rightBarButtonItem = moreButton
    }

    private func updateCounter() {
        let count = viewModel?.imageURLs.count ?? 0
        title = count > 1 ? "\(currentIndex + 1) / \(count)" : nil
    }

    // MARK: - Actions
    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func optionsTapped() {
        guard let actions = viewModel?.actions, actions.isNotEmpty else { return }
        router?.presentBottomSheet(actions: actions)
    }

    private func toggleUI() {
        isUIVisible.toggle()
        UIView.animate(withDuration: 0.25) {
            let alpha: CGFloat = self.isUIVisible ? 1 : 0
            self.navigationController?.navigationBar.alpha = alpha
            self.infoView.alpha = alpha
        }
    }

    private func configureInfo() {
        guard let info = viewModel?.info else {
            infoView.isHidden = true
            return
        }
        infoView.configure(with: info)
    }

    // MARK: - Interactive Dismiss
    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            let progress = translation.y / view.bounds.height
            let scale = max(1 - abs(progress) * 0.4, 0.6)

            collectionView.transform = CGAffineTransform(scaleX: scale, y: scale)
                .translatedBy(x: 0, y: translation.y / scale)
            view.backgroundColor = UIColor.black.withAlphaComponent(max(1 - abs(progress) * 1.5, 0))

            let uiAlpha = max(1 - abs(progress) * 3, 0)
            navigationController?.navigationBar.alpha = uiAlpha
            infoView.alpha = uiAlpha

        case .ended, .cancelled:
            let shouldDismiss = abs(translation.y) > dismissTranslation || abs(velocity.y) > dismissVelocity
            guard shouldDismiss else {
                restoreAfterPan()
                return
            }

            let targetY = velocity.y > 0 ? view.bounds.height : -view.bounds.height
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
                self.collectionView.transform = CGAffineTransform(translationX: 0, y: targetY)
                    .scaledBy(x: 0.5, y: 0.5)
                self.view.backgroundColor = .clear
                self.navigationController?.navigationBar.alpha = 0
                self.infoView.alpha = 0
            } completion: { _ in
                self.dismiss(animated: false)
            }

        default:
            break
        }
    }

    private func restoreAfterPan() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.collectionView.transform = .identity
            self.view.backgroundColor = .black
            guard self.isUIVisible else { return }
            self.navigationController?.navigationBar.alpha = 1
            self.infoView.alpha = 1
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PhotoViewerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard !isZoomed else { return false }
        let velocity = pan.velocity(in: view)
        return abs(velocity.y) > abs(velocity.x) * 1.5
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoViewerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.imageURLs.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoViewerCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: viewModel?.imageURLs[safe: indexPath.item] ?? "")
        cell.onSingleTap = { [weak self] in
            self?.toggleUI()
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoViewerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width > 0, let count = viewModel?.imageURLs.count else { return }
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        guard page >= 0, page < count, page != currentIndex else { return }
        currentIndex = page
        updateCounter()
    }
}

// MARK: - Draw
extension PhotoViewerViewController {
    private func draw() {
        view.addSubview(collectionView)
        view.addSubview(infoView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        infoView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
