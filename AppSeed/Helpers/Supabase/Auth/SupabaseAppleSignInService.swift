//
//  SupabaseAppleSignInService.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import UIKit
import AuthenticationServices
import Supabase

// MARK: - Protocol
protocol AppleSignInServiceProtocol {
    func signIn(from viewController: UIViewController,
                completion: @escaping (Result<AppleSignInResult, Error>) -> Void)
}

// MARK: - Service
final class SupabaseAppleSignInService: AppleSignInServiceProtocol {

    // MARK: - Properties
    private var currentDelegate: SupabaseAppleAuthorizationDelegate?

    // MARK: - Sign In
    func signIn(from viewController: UIViewController,
                completion: @escaping (Result<AppleSignInResult, Error>) -> Void) {

        let nonce = NonceGenerator.random()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = NonceGenerator.sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])

        let delegate = SupabaseAppleAuthorizationDelegate(
            nonce: nonce,
            anchorViewController: viewController
        ) { [weak self] result in
            completion(result)
            self?.currentDelegate = nil
        }

        currentDelegate = delegate
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        controller.performRequests()
    }
}
