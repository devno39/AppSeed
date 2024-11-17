//
//  ViewModelTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import Foundation

// MARK: - Source
protocol TutorialViewModelDataSource { }

// MARK: - Closure
protocol TutorialViewModelClosureSource { }

// MARK: - Function
protocol TutorialViewModelFunctionSource { }

// MARK: - Protocol
protocol TutorialViewModelProtocol: BaseViewModel, TutorialViewModelDataSource, TutorialViewModelClosureSource, TutorialViewModelFunctionSource { }

// MARK: - ViewModel
final class TutorialViewModel: BaseViewModel, TutorialViewModelProtocol {
    // MARK: - Source

    // MARK: - Closure

    // MARK: - Function
}
