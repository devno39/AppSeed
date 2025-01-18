//
//  SplashViewModel.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import Foundation

// MARK: - Source
protocol SplashViewModelDataSource {
    var title: String { get }
}

// MARK: - Closure
protocol SplashViewModelClosureSource {
    var requestsClosure: EmptyClosure? { get }
}

// MARK: - Function
protocol SplashViewModelFunctionSource {
    func requestGPT()
}

// MARK: - Protocol
protocol SplashViewModelProtocol: BaseViewModel, SplashViewModelDataSource, SplashViewModelClosureSource, SplashViewModelFunctionSource { }

// MARK: - ViewModel
final class SplashViewModel: BaseViewModel, SplashViewModelProtocol {
    // MARK: - Source
    var title: String = "splash"
    
    // MARK: - Service
    private var gptService: GptServiceProtocol?

    // MARK: - Closure
    var requestsClosure: EmptyClosure?
    
    // MARK: - Init
    init(gptService: GptServiceProtocol) {
        super.init()
        self.gptService = gptService
    }

    // MARK: - Function
    func requestFake() {
        LoadingHelper.shared.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            LoadingHelper.shared.hideLoading()
            self.requestsClosure?()
        }
    }
    
    func requestGPT() {
        let message = "hi dude <3"
        let request = RequestGPT(userMessage: message)
        gptService?.requestGPT(request: request) { [weak self] response in
            guard let self else { return }
            debugPrint(response?.message ?? "")
        }
    }
    
    func requestDALLE() {
        let prompt = "a futuristic cityscape with flying cars and neon lights"
        let request = RequestDALLE(prompt: prompt)
        gptService?.requestDalle(request: request) { [weak self] response in
            guard let self else { return }
            debugPrint(response?.imageUrl ?? "")
        }
    }
}
