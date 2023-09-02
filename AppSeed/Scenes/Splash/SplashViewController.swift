//
//  SplashViewController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

final class SplashViewController: BaseViewController<SplashViewModel> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        print("my title is", viewModel.title ?? "")
        viewModel.getSomething()
    }
}

// MARK: - ViewModel Delegate
extension SplashViewController: SplashViewModelDelegate {
    func didGetSomething() {
        print("i got that")
    }
}
