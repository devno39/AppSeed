//
//  FeedbackSheetViewModel.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import Foundation

// MARK: - Source
protocol FeedbackSheetViewModelDataSource {
    var feedbackText: String { get set }
    var isSendEnabled: Bool { get }
}

// MARK: - Closure
protocol FeedbackSheetViewModelClosureSource {
    var onSendSuccess: EmptyClosure? { get set }
    var onSendFailure: EmptyClosure? { get set }
    var validationDidChange: EmptyClosure? { get set }
}

// MARK: - Function
protocol FeedbackSheetViewModelFunctionSource {
    func sendFeedback()
}

// MARK: - Protocol
protocol FeedbackSheetViewModelProtocol: FormBottomSheetViewModelProtocol,
                                         FeedbackSheetViewModelDataSource,
                                         FeedbackSheetViewModelClosureSource,
                                         FeedbackSheetViewModelFunctionSource {}

// MARK: - ViewModel
final class FeedbackSheetViewModel: FormBottomSheetViewModel, FeedbackSheetViewModelProtocol {

    // MARK: - Source
    var feedbackText: String = "" {
        didSet { validationDidChange?() }
    }

    var isSendEnabled: Bool {
        !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Closure
    var onSendSuccess: EmptyClosure?
    var onSendFailure: EmptyClosure?
    var validationDidChange: EmptyClosure?

    // MARK: - Function
    func sendFeedback() {
        let message = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        let onSuccess = onSendSuccess
        let onFailure = onSendFailure

        LoadingHelper.shared.showLoading()
        FeedbackHelper.shared.sendFeedback(message: message) { success in
            LoadingHelper.shared.hideLoading()
            if success {
                onSuccess?()
            } else {
                onFailure?()
            }
        }
    }
}
