//
//  SupabaseAppleAuthorizationDelegate.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import UIKit
import AuthenticationServices
import Supabase

struct AppleSignInResult {
    let user: Auth.User
    let fullName: String?
}

final class SupabaseAppleAuthorizationDelegate: NSObject {

    enum AppleAuthError: Error {
        case missingIdentityToken
        case invalidTokenEncoding
    }

    // MARK: - Properties
    private let nonce: String
    private let completion: (Result<AppleSignInResult, Error>) -> Void
    private weak var anchorViewController: UIViewController?

    // MARK: - Init
    init(nonce: String,
         anchorViewController: UIViewController,
         completion: @escaping (Result<AppleSignInResult, Error>) -> Void) {
        self.nonce = nonce
        self.anchorViewController = anchorViewController
        self.completion = completion
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension SupabaseAppleAuthorizationDelegate: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completion(.failure(AppleAuthError.missingIdentityToken))
            return
        }

        guard let tokenData = appleIDCredential.identityToken else {
            completion(.failure(AppleAuthError.missingIdentityToken))
            return
        }

        guard let idTokenString = String(data: tokenData, encoding: .utf8) else {
            completion(.failure(AppleAuthError.invalidTokenEncoding))
            return
        }

        let givenName = appleIDCredential.fullName?.givenName?.trimmingCharacters(in: .whitespaces) ?? ""
        let familyName = appleIDCredential.fullName?.familyName?.trimmingCharacters(in: .whitespaces) ?? ""
        let composed = [givenName, familyName].filter { !$0.isEmpty }.joined(separator: " ")
        let fullName = composed.isEmpty ? nil : composed

        Task {
            do {
                let session = try await SupabaseManager.shared.client.auth.signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: idTokenString, nonce: nonce)
                )
                await MainActor.run {
                    self.completion(.success(AppleSignInResult(user: session.user, fullName: fullName)))
                }
            } catch {
                Self.logSIWAError(error, stage: "Supabase exchange")
                await MainActor.run {
                    self.completion(.failure(error))
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Self.logSIWAError(error, stage: "Apple")
        completion(.failure(error))
    }

    static func logSIWAError(_ error: Error, stage: String) {
        let ns = error as NSError
        log(.error, .supabase, "SIWA error (\(stage)) domain=\(ns.domain) code=\(ns.code) desc=\(ns.localizedDescription)")
    }
}

// MARK: - Presentation Anchor
extension SupabaseAppleAuthorizationDelegate: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = anchorViewController?.view.window {
            return window
        }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow }) ?? UIWindow()
    }
}
