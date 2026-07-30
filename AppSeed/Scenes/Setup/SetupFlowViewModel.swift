//
//  SetupFlowViewModel.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// MARK: - Source
protocol SetupFlowViewModelDataSource {
    var displayName: String { get set }
    var birthDate: Date? { get set }
    var isSaveEnabled: Bool { get }
}

// MARK: - Closure
protocol SetupFlowViewModelClosureSource {
    var onComplete: EmptyClosure? { get set }
    var validationDidChange: EmptyClosure? { get set }
}

// MARK: - Protocol
protocol SetupFlowViewModelProtocol: FormBottomSheetViewModelProtocol, SetupFlowViewModelDataSource, SetupFlowViewModelClosureSource {}

// MARK: - ViewModel
final class SetupFlowViewModel: FormBottomSheetViewModel, SetupFlowViewModelProtocol {

    // MARK: - Services
    private let userService: UserServiceProtocol

    // MARK: - Source
    var displayName: String = "" {
        didSet { validationDidChange?() }
    }
    var birthDate: Date? {
        didSet { validationDidChange?() }
    }

    var isSaveEnabled: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Closure
    var onComplete: EmptyClosure?
    var validationDidChange: EmptyClosure?

    // MARK: - Init
    init(userService: UserServiceProtocol) {
        self.userService = userService
        super.init()
    }

    // MARK: - Function
    func saveProfile() {
        guard let userId = userService.currentUserId else { return }
        var fields: [String: Any] = [
            "display_name": displayName.trimmingCharacters(in: .whitespaces)
        ]
        if let birthDate {
            fields["birth_date"] = birthDate
        }
        userService.updateProfile(userId: userId, fields: fields, completion: nil)
        ReviewPromptManager.recordMilestone()
    }
}
