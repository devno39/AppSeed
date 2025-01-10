//
//  BaseViewController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

class BaseViewController<V: BaseViewModelProtocol, R: BaseRouterProtocol>: UIViewController {
    // MARK: - UI
    private let hudView = HudView()
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    // MARK: - Properties
    var isScrollable: Bool { false }
    
    // MARK: - Dependency
    var viewModel: V?
    var router: R?

    // MARK: - Init
    required init(viewModel: V, router: R) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        self.router?.viewController = self
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("🔴 deinit: ", self.description)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }
    
    // MARK: - Prapare
    func prepare() {
        debugPrint("🟢 didload: ", self.description)
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        draw()
    }

    // MARK: - Bind
    func bindViewModel() {
        viewModel?.loading = { [weak self] isLoading in
            guard let self, let isLoading else { return }
            DispatchQueue.main.async {
                if isLoading ?? false {
                    self.showHud()
                } else {
                    self.hideHud()
                }
            }
        }
    }

    // MARK: - Hud
    private func showHud() {
        view.addSubview(hudView)
        hudView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func hideHud() {
        hudView.removeFromSuperview()
    }
}

// MARK: - Draw
extension BaseViewController {
    private func draw() {
        if isScrollable {
            view.addSubview(scrollView)
            scrollView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            scrollView.addSubview(stackView)
            stackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.width.equalToSuperview()
            }
        }
    }
}

// MARK: - ScrollView
extension BaseViewController {
    func addToScrollView(_ view: UIView) {
        guard isScrollable else { return }
        stackView.addArrangedSubview(view)
    }
    
    func addToScrollView(_ views: [UIView]) {
        guard isScrollable else { return }
        views.forEach { stackView.addArrangedSubview($0) }
    }
    
    func setScrollViewInsets(top: CGFloat, bottom: CGFloat) {
        guard isScrollable else { return }
        scrollView.contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0)
    }
    
    func setScrollViewStackInsets(left: CGFloat, right: CGFloat) {
        guard isScrollable else { return }
        stackView.snp.updateConstraints {
            $0.left.equalToSuperview().offset(left)
            $0.right.equalToSuperview().offset(-right)
            $0.width.equalToSuperview().inset((left + right) / 2)
        }
    }
    
    func setScrollViewStackSpacing(_ spacing: CGFloat) {
        guard isScrollable else { return }
        stackView.spacing = spacing
    }
    
    func setSpacingAfter(spacing: CGFloat, after view: UIView) {
        guard isScrollable else { return }
        stackView.setCustomSpacing(spacing, after: view)
    }
}
