//
//  HomeViewModel.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import Foundation

// MARK: - Source
protocol HomeViewModelDataSource { }

// MARK: - Closure
protocol HomeViewModelClosureSource { }

// MARK: - Protocol
protocol HomeViewModelProtocol: BaseViewModel, HomeViewModelDataSource, HomeViewModelClosureSource { }

// MARK: - ViewModel
final class HomeViewModel: BaseViewModel, HomeViewModelProtocol { }
