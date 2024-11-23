//
//  BaseViewModel.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit.UIViewController

// MARK: - Source
protocol BaseViewModelDataSource { }

// MARK: - Closure
protocol BaseViewModelClosureSource {
    var loading: OptinalAnyClosure<Bool?>? { get set }
}

// MARK: - Function
protocol BaseViewModelFunctionSource { }

// MARK: - Protocol
protocol BaseViewModelProtocol: AnyObject, BaseViewModelDataSource, BaseViewModelClosureSource, BaseViewModelFunctionSource { }

class BaseViewModel: BaseViewModelProtocol {
    // MARK: - Closures
    var loading: OptinalAnyClosure<Bool?>?

    deinit {
        // TODO: - create a custom logger
    }
}
