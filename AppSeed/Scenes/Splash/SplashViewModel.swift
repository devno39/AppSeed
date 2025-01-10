//
//  SplashViewModel.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import Foundation

// MARK: - Source
protocol SplashViewModelDataSource {
    var title: String { get }
}

// MARK: - Closure
protocol SplashViewModelClosureSource {
    var requestClosure: EmptyClosure? { get }
}

// MARK: - Function
protocol SplashViewModelFunctionSource {
    func request()
}

// MARK: - Protocol
protocol SplashViewModelProtocol: BaseViewModel, SplashViewModelDataSource, SplashViewModelClosureSource, SplashViewModelFunctionSource { }

// MARK: - ViewModel
final class SplashViewModel: BaseViewModel, SplashViewModelProtocol {
    // MARK: - Source
    var title: String = "splash"

    // MARK: - Closure
    var requestClosure: EmptyClosure?

    // MARK: - Function
    func request() {
        loading?(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            loading?(false)
            requestClosure?()
        }
    }
}
