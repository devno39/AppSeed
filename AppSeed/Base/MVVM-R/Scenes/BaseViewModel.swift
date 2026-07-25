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
protocol BaseViewModelClosureSource { }

// MARK: - Function
protocol BaseViewModelFunctionSource { }

// MARK: - Protocol
protocol BaseViewModelProtocol: AnyObject, BaseViewModelDataSource, BaseViewModelClosureSource, BaseViewModelFunctionSource { }

class BaseViewModel: BaseViewModelProtocol {
    // MARK: - Closures

    deinit {
        // TODO: - create a custom logger
    }
}
