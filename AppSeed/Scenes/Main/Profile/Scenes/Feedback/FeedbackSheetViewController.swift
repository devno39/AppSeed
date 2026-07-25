//
//  FeedbackSheetViewController.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class FeedbackSheetViewController: FormBottomSheetViewController<FeedbackSheetViewModel, FeedbackSheetRouter> {

    // MARK: - UI
    private lazy var feedbackField: FormTextView = {
        FormTextView(
            title: ProfileLocalizable.feedback_message_title,
            placeholder: ProfileLocalizable.feedback_message_placeholder
        )
    }()

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        setupForm()
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()

        viewModel?.onSave = { [weak self] in
            self?.viewModel?.sendFeedback()
        }

        viewModel?.validationDidChange = { [weak self] in
            guard let self else { return }
            self.updateSaveButton(enabled: self.viewModel?.isSendEnabled ?? false)
        }

        viewModel?.onSendSuccess = { [weak self] in
            self?.dismiss(animated: true) {
                ToastHelper.show(
                    icon: "checkmark.seal.fill",
                    title: ProfileLocalizable.feedback_success_title,
                    subtitle: ProfileLocalizable.feedback_success_message
                )
            }
        }

        viewModel?.onSendFailure = {
            AlertHelper.showAlert(
                title: ProfileLocalizable.feedback_error_title,
                message: ProfileLocalizable.feedback_error_message
            )
        }

        feedbackField.onTextChange = { [weak self] text in
            self?.viewModel?.feedbackText = text
        }
    }

    // MARK: - Private
    private func setupForm() {
        addFormItem(feedbackField)
    }
}
