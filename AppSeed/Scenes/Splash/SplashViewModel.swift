//
//  SplashViewModel.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import Foundation

// MARK: - Source
protocol SplashViewModelDataSource {
    var title: String? { get }
}

// MARK: - Delegate
protocol SplashViewModelDelegate {
    func didGetSomething()
}

// MARK: - Protocol
protocol SplashViewModelProtocol: SplashViewModelDataSource {
    func getSomething()
}

// MARK: - ViewModel
final class SplashViewModel: BaseViewModel<SplashRouter, SplashViewModelDelegate>, SplashViewModelProtocol {
    var title: String? { "splash" }
    
    func getSomething() {
        delegate?.didGetSomething()
    }
    
    func navigateToHome() {
        
    }
}
