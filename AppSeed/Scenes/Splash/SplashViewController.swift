//
//  SplashViewController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit
import SnapKit

final class SplashViewController: BaseViewController<SplashViewModel> {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        print("my title is", viewModel.title ?? "")
        viewModel.getSomething()
        
        showHud()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hideHud()
        }
    }
    
    override func prepare() {
        super.prepare()
        
        draw()
    }
}

// MARK: - ViewModel Delegate
extension SplashViewController: SplashViewModelDelegate {
    func didGetSomething() {
        print("i got that")
    }
}

// MARK: - Draw
private extension SplashViewController {
    private func draw() {}
}
