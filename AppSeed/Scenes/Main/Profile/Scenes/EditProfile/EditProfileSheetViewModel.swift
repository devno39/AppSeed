//
//  EditProfileSheetViewModel.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// MARK: - Source
protocol EditProfileSheetViewModelDataSource {
    var image: UIImage? { get set }
    var displayName: String { get set }
    var birthDate: Date? { get set }
    var existingImageUrl: String? { get set }
    var isSaveEnabled: Bool { get }
}

// MARK: - Closure
protocol EditProfileSheetViewModelClosureSource {
    var onSaveProfile: AnyClosure<EditProfileModel>? { get set }
    var validationDidChange: EmptyClosure? { get set }
}

// MARK: - Protocol
protocol EditProfileSheetViewModelProtocol: FormBottomSheetViewModelProtocol,
                                            EditProfileSheetViewModelDataSource,
                                            EditProfileSheetViewModelClosureSource {}

// MARK: - ViewModel
final class EditProfileSheetViewModel: FormBottomSheetViewModel, EditProfileSheetViewModelProtocol {

    // MARK: - Initial State
    private var initialDisplayName: String = ""
    private var initialBirthDate: Date?

    // MARK: - Source
    var image: UIImage? {
        didSet { validationDidChange?() }
    }
    var displayName: String = "" {
        didSet { validationDidChange?() }
    }
    var birthDate: Date? {
        didSet { validationDidChange?() }
    }
    var existingImageUrl: String?

    var isSaveEnabled: Bool {
        hasChanges && !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var hasChanges: Bool {
        image != nil ||
        displayName.trimmingCharacters(in: .whitespaces) != initialDisplayName.trimmingCharacters(in: .whitespaces) ||
        birthDate != initialBirthDate
    }

    // MARK: - Snapshot
    func saveInitialState() {
        initialDisplayName = displayName
        initialBirthDate = birthDate
    }

    // MARK: - Closure
    var onSaveProfile: AnyClosure<EditProfileModel>?
    var validationDidChange: EmptyClosure?

    // MARK: - Function
    func buildModel() -> EditProfileModel {
        EditProfileModel(
            image: image,
            displayName: displayName.trimmingCharacters(in: .whitespaces),
            birthDate: birthDate
        )
    }
}
