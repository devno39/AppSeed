//
//  LoginViewModel.swift
//  AppSeed
//
//  Created by Claude on 19.01.2025.
//

import UIKit
import Supabase

// MARK: - Source
protocol LoginViewModelDataSource { }

// MARK: - Closure
protocol LoginViewModelClosureSource {
    var loginSuccessClosure: AnyClosure<String>? { get }
}

// MARK: - Function
protocol LoginViewModelFunctionSource {
    func appleSignIn(_ from: UIViewController)
}

// MARK: - Protocol
protocol LoginViewModelProtocol: BaseViewModel, LoginViewModelDataSource, LoginViewModelClosureSource, LoginViewModelFunctionSource { }

final class LoginViewModel: BaseViewModel, LoginViewModelProtocol {

    // MARK: - Closure
    var loginSuccessClosure: AnyClosure<String>?

    // MARK: - Services
    private let appleSignInService: AppleSignInServiceProtocol
    private let userService: UserServiceProtocol

    // MARK: - Init
    init(appleSignInService: AppleSignInServiceProtocol, userService: UserServiceProtocol) {
        self.appleSignInService = appleSignInService
        self.userService = userService
        super.init()
    }

    // MARK: - Apple Sign In
    func appleSignIn(_ from: UIViewController) {
        appleSignInService.signIn(from: from) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let appleResult):
                handleSuccessfulAuth(user: appleResult.user, appleFullName: appleResult.fullName)
            case .failure(let error):
                let mapped = SupabaseAppleSignInError.map(error)
                if case .cancelled = mapped {
                    ToastHelper.show(
                        icon: Symbols.info_circle.symbolName,
                        title: LoginLocalizable.apple_signin_error_cancelled
                    )
                    return
                }
                AlertHelper.showAlert(
                    title: LoginLocalizable.apple_signin_error_title,
                    message: mapped.errorDescription
                )
            }
        }
    }

    // MARK: - Auth Success
    private func handleSuccessfulAuth(user: Auth.User, appleFullName: String?) {
        let userId = user.id.uuidString.lowercased()

        var data: [String: Any] = [
            "user_id": userId,
            "last_login_at": ISO8601DateFormatter().string(from: Date())
        ]

        if let email = user.email {
            data["email"] = email
        }

        if let appleFullName, !appleFullName.isEmpty {
            data["display_name"] = appleFullName
        }

        userService.upsertOnLogin(userId: userId, data: data) { [weak self] error in
            guard error == nil else { return }
            self?.loginSuccessClosure?(userId)
        }
    }
}
