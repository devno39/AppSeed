//
//  UserServiceProtocol.swift
//  AppSeed
//
//  Created by Claude on 16.03.2026.
//

import Foundation

protocol UserServiceProtocol {
    // MARK: - Auth
    var currentUserId: String? { get }
    var isLoggedIn: Bool { get }
    func signOut() async throws

    // MARK: - Read
    func getUser(id: String, completion: @escaping AnyClosure<User?>)
    func listenUser(id: String, completion: @escaping AnyClosure<User?>) -> ListenerHandle

    // MARK: - Write
    func upsertOnLogin(userId: String, data: [String: Any], completion: AnyClosure<Error?>?)
    func updateProfile(userId: String, fields: [String: Any], completion: AnyClosure<Error?>?)

    // MARK: - Delete
    func deleteAccount(userId: String, completion: @escaping AnyClosure<Error?>)
}
