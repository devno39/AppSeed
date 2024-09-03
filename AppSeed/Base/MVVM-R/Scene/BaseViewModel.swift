//
//  BaseViewModel.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit.UIViewController

// MARK: - Delegate
protocol BaseViewModelDelegate { }

// MARK: - Source
protocol BaseViewModelDataSource { }

// MARK: - Protocol
protocol BaseViewModelProtocol: AnyObject, BaseViewModelDataSource {
    
}

class BaseViewModel<R: BaseRouter<U>, U: UIViewController, D: AnyObject>: BaseViewModelProtocol {
    
    let router: R
    weak var delegate: D?
    
    deinit {
        // TODO: - create a custom logger
    }
    
    required init(router: R) {
        self.router = router
    }
}
