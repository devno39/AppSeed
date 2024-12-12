//
//  ViewModelTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import Foundation

// MARK: - Source
protocol TutorialViewModelDataSource {
    var models: [TutorialUIModel] { get }
}

// MARK: - Closure
protocol TutorialViewModelClosureSource {
    var completedClosure: EmptyClosure? { get set }
}

// MARK: - Function
protocol TutorialViewModelFunctionSource {
    func numberOfItems() -> Int
    func getTutorial(_ index: Int) -> TutorialUIModel
}

// MARK: - Protocol
protocol TutorialViewModelProtocol: BaseViewModel, TutorialViewModelDataSource, TutorialViewModelClosureSource, TutorialViewModelFunctionSource { }

// MARK: - ViewModel
final class TutorialViewModel: BaseViewModel, TutorialViewModelProtocol {
    // MARK: - Source
    var models: [TutorialUIModel] = TutorialUIModel.getTutorialData()

    // MARK: - Closure
    var completedClosure: EmptyClosure?

    // MARK: - Function
    func numberOfItems() -> Int {
        return models.count
    }
    
    func getTutorial(_ index: Int) -> TutorialUIModel {
        return models[index]
    }
}
