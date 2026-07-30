//
//  AddItemSheetViewModel.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import Foundation

// MARK: - Source
protocol AddItemSheetViewModelDataSource {
    var title: String { get set }
    var note: String { get set }
    var emoji: String? { get set }
    var isSaveEnabled: Bool { get }
}

// MARK: - Closure
protocol AddItemSheetViewModelClosureSource {
    var onSubmit: AnyClosure<AddItemModel>? { get set }
    var validationDidChange: EmptyClosure? { get set }
}

// MARK: - Protocol
protocol AddItemSheetViewModelProtocol: FormBottomSheetViewModelProtocol,
                                        AddItemSheetViewModelDataSource,
                                        AddItemSheetViewModelClosureSource { }

// MARK: - ViewModel
final class AddItemSheetViewModel: FormBottomSheetViewModel, AddItemSheetViewModelProtocol {

    // MARK: - Source
    var title: String = "" {
        didSet { validationDidChange?() }
    }
    var note: String = "" {
        didSet { validationDidChange?() }
    }
    var emoji: String? {
        didSet { validationDidChange?() }
    }

    var isSaveEnabled: Bool {
        title.trimmingCharacters(in: .whitespaces).isNotEmpty
    }

    // MARK: - Closure
    var onSubmit: AnyClosure<AddItemModel>?
    var validationDidChange: EmptyClosure?

    // MARK: - Function
    func buildModel() -> AddItemModel {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        return AddItemModel(
            title: title.trimmingCharacters(in: .whitespaces),
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            emoji: emoji
        )
    }
}
