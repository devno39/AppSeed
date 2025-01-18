//
//  ViewModelTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import Foundation

// MARK: - Source
protocol ScrollTestViewModelDataSource { }

// MARK: - Closure
protocol ScrollTestViewModelClosureSource { }

// MARK: - Function
protocol ScrollTestViewModelFunctionSource { }

// MARK: - Protocol
protocol ScrollTestViewModelProtocol: BaseViewModel, ScrollTestViewModelDataSource, ScrollTestViewModelClosureSource, ScrollTestViewModelFunctionSource { }

// MARK: - ViewModel
final class ScrollTestViewModel: BaseViewModel, ScrollTestViewModelProtocol {
    // MARK: - Source

    // MARK: - Closure

    // MARK: - Function
}
