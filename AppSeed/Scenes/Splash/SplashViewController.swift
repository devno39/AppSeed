//
//  SplashViewController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit
import SnapKit

final class SplashViewController: BaseViewController<SplashViewModel, SplashRouter> {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.request()
    }
    
    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        draw()
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
        viewModel?.requestClosure = { [weak self] string in
            guard let self else { return }
            routeTutorial()
        }
    }

    // MARK: - Route
    private func routeTutorial() {
        router?.showTutorail()
    }
}

// MARK: - Draw
private extension SplashViewController {
    private func draw() { }
}
