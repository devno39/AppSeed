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
    var isUserLoggedIn: Bool { get }
}

// MARK: - Closure
protocol SplashViewModelClosureSource {
    var groupClosure: EmptyClosure? { get }
}

// MARK: - Function
protocol SplashViewModelFunctionSource {
    func checkUpdate(completion: BoolClosure?)
    func afterCheckUpdate()
}

// MARK: - Protocol
protocol SplashViewModelProtocol: BaseViewModel, SplashViewModelDataSource, SplashViewModelClosureSource, SplashViewModelFunctionSource { }

// MARK: - ViewModel
final class SplashViewModel: BaseViewModel, SplashViewModelProtocol {
    // MARK: - Source
    var title: String = "splash"

    // MARK: - Services
    private let userService: UserServiceProtocol

    var isUserLoggedIn: Bool { userService.isLoggedIn }

    // MARK: - Closure
    var groupClosure: EmptyClosure?

    // MARK: - Init
    init(userService: UserServiceProtocol) {
        self.userService = userService
        super.init()
    }

    // MARK: - Function
    func requestFake() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.groupClosure?()
        }
    }

    func checkUpdate(completion: BoolClosure?) {
        // A slow config fetch must not hold the splash hostage — after the grace
        // window the app proceeds unchecked and the late result is discarded.
        var didFinish = false
        let finish: BoolClosure = { needsUpdate in
            guard !didFinish else { return }
            didFinish = true
            completion?(needsUpdate)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            finish(false)
        }

        SupabaseAppConfigHelper.shared.fetchAll { _ in
            guard let remoteVersion: String = SupabaseAppConfigHelper.shared.getValue(for: .minimumSupportedVersion) else {
                finish(false)
                return
            }

            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
            finish(appVersion.compare(remoteVersion, options: .numeric) == .orderedAscending)
        }
    }

    func afterCheckUpdate() {
        PermissionManager.shared.refreshNotificationStatus()
        if isUserLoggedIn {
            UserSessionManager.shared.startListening()
        }
        requestFake()
    }
}
