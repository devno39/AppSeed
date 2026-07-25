//
//  FormBottomSheetViewModel.swift
//  AppSeed
//
//  Created by Codex on 28.02.2026.
//

import Foundation

// MARK: - Source
protocol FormBottomSheetViewModelDataSource {
    var sheetTitle: String? { get set }
    var sheetSubtitle: String? { get set }
    var saveTitle: String { get set }
    var cornerRadius: CGFloat { get }
}

// MARK: - Closure
protocol FormBottomSheetViewModelClosureSource {
    var onSave: EmptyClosure? { get set }
    var onDismiss: EmptyClosure? { get set }
}

// MARK: - Protocol
protocol FormBottomSheetViewModelProtocol: BaseViewModelProtocol, FormBottomSheetViewModelDataSource, FormBottomSheetViewModelClosureSource {}

// MARK: - ViewModel
class FormBottomSheetViewModel: BaseViewModel, FormBottomSheetViewModelProtocol {
    // MARK: - Source
    var sheetTitle: String?
    var sheetSubtitle: String?
    var saveTitle: String = "Save"
    var cornerRadius: CGFloat { 24 }

    // MARK: - Closure
    var onSave: EmptyClosure?
    var onDismiss: EmptyClosure?
}
