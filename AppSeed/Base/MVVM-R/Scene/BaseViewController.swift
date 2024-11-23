//
//  BaseViewController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

class BaseViewController<V: BaseViewModelProtocol, R: BaseRouterProtocol>: UIViewController {
    // MARK: - Properties
    private let hudView = HudView()
    
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
        debugPrint("deinit controller: ", self.description)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }
    
    // MARK: - Prapare
    func prepare() {
        view.backgroundColor = ColorBackground.backgroundPrimary.color
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
