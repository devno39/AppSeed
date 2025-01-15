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
    var requestClosure: EmptyClosure? { get }
}

// MARK: - Function
protocol SplashViewModelFunctionSource {
    func request()
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
    var requestClosure: EmptyClosure?
    
    // MARK: - Init
    init(gptService: GptServiceProtocol) {
        super.init()
        self.gptService = gptService
    }

    // MARK: - Function
    func request() {
        loading?(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            loading?(false)
            requestClosure?()
        }
    }
    
    // TODO: - This is just an example request as gpt, remove before flight 🚀
    func requestGPT() {
        loading?(true)
        let message = "hi dude <3"
        let request = RequestGPT(userMessage: message)
        gptService?.postMessage(request: request) { [weak self] response in
            guard let self else { return }
            print(response?.message ?? "")
            loading?(false)
        }
    }
}
