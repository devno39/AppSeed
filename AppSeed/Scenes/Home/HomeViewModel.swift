//
//  HomeViewModel.swift
//  AppSeed
//
//  Created by tunay alver on 26.08.2024.
//

import Foundation

// MARK: - Source
protocol HomeViewModelDataSource {
    var title: String? { get }
}

// MARK: - Delegate
protocol HomeViewModelDelegate {}

// MARK: - Protocol
protocol HomeViewModelProtocol: HomeViewModelDataSource {}

// MARK: - ViewModel
final class HomeViewModel: BaseViewModel<HomeRouter, HomeViewModelDelegate>, HomeViewModelProtocol {
    var title: String? { "home" }
    
}
