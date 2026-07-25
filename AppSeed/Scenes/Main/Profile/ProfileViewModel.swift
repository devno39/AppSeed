//
//  ProfileViewModel.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import Foundation
import UIKit

// MARK: - Source
protocol ProfileViewModelDataSource {
    var headerModel: ProfileHeaderModel { get }
    var currentUser: User? { get }
}

// MARK: - Closure
protocol ProfileViewModelClosureSource {
    var dataDidChange: EmptyClosure? { get set }
    var editProfileClosure: EmptyClosure? { get set }
    var logoutSuccessClosure: EmptyClosure? { get set }
    var deleteAccountSuccessClosure: EmptyClosure? { get set }
}

// MARK: - Function
protocol ProfileViewModelFunctionSource {
    func fetchUser()
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func section(at index: Int) -> ProfileSection?
    func item(at indexPath: IndexPath) -> ProfileCellType?
    func logout()
    func deleteAccount()
    func updateProfile(with model: EditProfileModel)
}

// MARK: - Protocol
protocol ProfileViewModelProtocol: BaseViewModel,
                                   ProfileViewModelDataSource,
                                   ProfileViewModelClosureSource,
                                   ProfileViewModelFunctionSource { }

final class ProfileViewModel: BaseViewModel, ProfileViewModelProtocol {

    // MARK: - Source
    private(set) var headerModel = ProfileHeaderModel(userName: nil, email: nil, avatarURL: nil)
    private(set) var currentUser: User?
    private var sections: [ProfileSection] = []

    // MARK: - Services
    private let userService: UserServiceProtocol

    // MARK: - Closure
    var dataDidChange: EmptyClosure?
    var editProfileClosure: EmptyClosure?
    var logoutSuccessClosure: EmptyClosure?
    var deleteAccountSuccessClosure: EmptyClosure?

    // MARK: - Init
    init(userService: UserServiceProtocol) {
        self.userService = userService
        super.init()
    }

    // MARK: - Fetch
    func fetchUser() {
        guard let user = UserSessionManager.shared.currentUser else { return }
        currentUser = user
        headerModel = ProfileHeaderModel(
            userName: user.displayName,
            email: user.email,
            avatarURL: user.avatarURL
        )
        sections = buildSections()
        dataDidChange?()
    }

    // MARK: - DataSource
    func numberOfSections() -> Int {
        sections.count
    }

    func numberOfItems(in sectionIndex: Int) -> Int {
        guard sectionIndex < sections.count else { return 0 }
        return sections[sectionIndex].cells.count
    }

    func section(at index: Int) -> ProfileSection? {
        guard index < sections.count else { return nil }
        return sections[index]
    }

    func item(at indexPath: IndexPath) -> ProfileCellType? {
        guard indexPath.section < sections.count else { return nil }
        let cells = sections[indexPath.section].cells
        guard indexPath.row < cells.count else { return nil }
        return cells[indexPath.row]
    }

    // MARK: - Update
    func updateProfile(with model: EditProfileModel) {
        guard let userId = userService.currentUserId else { return }

        if let image = model.image {
            SupabaseStorageHelper.uploadImage(image, path: .profileImages, fileName: userId) { [weak self] avatarURL in
                self?.saveProfileData(userId: userId, model: model, avatarURL: avatarURL)
            }
        } else {
            saveProfileData(userId: userId, model: model, avatarURL: nil)
        }
    }

    private func saveProfileData(userId: String, model: EditProfileModel, avatarURL: String?) {
        var data: [String: Any] = ["display_name": model.displayName]
        if let birthDate = model.birthDate {
            data["birth_date"] = birthDate
        }
        let finalAvatarURL = avatarURL ?? currentUser?.avatarURL
        if let avatarURL {
            data["avatar_url"] = avatarURL
        }

        userService.updateProfile(userId: userId, fields: data, completion: nil)

        headerModel = ProfileHeaderModel(
            userName: model.displayName,
            email: currentUser?.email,
            avatarURL: finalAvatarURL
        )
        currentUser = User(
            userId: userId,
            displayName: model.displayName,
            email: currentUser?.email,
            avatarURL: finalAvatarURL,
            birthDate: model.birthDate,
            createdAt: currentUser?.createdAt,
            lastLoginAt: currentUser?.lastLoginAt,
            lastSeenAt: currentUser?.lastSeenAt
        )
        dataDidChange?()
    }

    // MARK: - Logout
    func logout() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                // Server first — a failed signOut must not leave a half-wiped signed-in state.
                try await self.userService.signOut()
                UserSessionManager.shared.stopListening(wipeCache: true)
                self.logoutSuccessClosure?()
            } catch {
                log(.error, .supabase, "Logout failed: \(error.localizedDescription)")
                AlertHelper.showAlert(
                    title: ProfileLocalizable.logout_failed_title,
                    message: ProfileLocalizable.logout_failed_message
                )
            }
        }
    }

    // MARK: - Delete Account
    func deleteAccount() {
        guard let userId = userService.currentUserId else { return }
        userService.deleteAccount(userId: userId) { [weak self] error in
            guard let self else { return }
            if let error {
                log(.error, .supabase, "Delete account failed: \(error.localizedDescription)")
                AlertHelper.showAlert(
                    title: ProfileLocalizable.delete_account_failed_title,
                    message: ProfileLocalizable.delete_account_failed_message
                )
                return
            }
            // Local teardown only after the server confirmed — a failed RPC keeps the session intact.
            UserSessionManager.shared.stopListening(wipeCache: true)
            self.deleteAccountSuccessClosure?()
        }
    }

    // MARK: - Private
    private func buildSections() -> [ProfileSection] {
        [.header, .premium, .account, .app, .session]
    }
}
