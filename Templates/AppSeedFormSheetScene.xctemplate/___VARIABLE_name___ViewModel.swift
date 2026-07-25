//
//  ___VARIABLE_name___ViewModel.swift
//  AppSeed
//

import Foundation

// MARK: - Source
protocol ___VARIABLE_name___ViewModelDataSource {
    var text: String { get set }
    var isSaveEnabled: Bool { get }
}

// MARK: - Closure
protocol ___VARIABLE_name___ViewModelClosureSource {
    var onSaveSuccess: EmptyClosure? { get set }
    var validationDidChange: EmptyClosure? { get set }
}

// MARK: - Function
protocol ___VARIABLE_name___ViewModelFunctionSource {
    func save()
}

// MARK: - Protocol
protocol ___VARIABLE_name___ViewModelProtocol: FormBottomSheetViewModelProtocol,
                                               ___VARIABLE_name___ViewModelDataSource,
                                               ___VARIABLE_name___ViewModelClosureSource,
                                               ___VARIABLE_name___ViewModelFunctionSource { }

// MARK: - ViewModel
final class ___VARIABLE_name___ViewModel: FormBottomSheetViewModel, ___VARIABLE_name___ViewModelProtocol {

    // MARK: - Source
    var text: String = "" {
        didSet { validationDidChange?() }
    }

    var isSaveEnabled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Closure
    var onSaveSuccess: EmptyClosure?
    var validationDidChange: EmptyClosure?

    // MARK: - Function
    func save() {
        // Persist via an injected service, then:
        onSaveSuccess?()
    }
}
