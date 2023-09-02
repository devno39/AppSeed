//
//  BaseViewModel.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import Foundation

// MARK: - Delegate
protocol BaseViewModelDelegate { }

// MARK: - Source
protocol BaseViewModelDataSource { }

// MARK: - Protocol
protocol BaseViewModelProtocol: BaseViewModelDataSource { }

class BaseViewModel<R: BaseRouter, D: Any>: BaseViewModelProtocol {
    
    private let router: R
    var delegate: D?
    
    deinit {
        // TODO: - create a custom logger
    }
    
    required init(router: R) {
        self.router = router
    }
}
