//
//  ___VARIABLE_name___ViewController.swift
//  AppSeed
//

import UIKit

final class ___VARIABLE_name___ViewController: FormBottomSheetViewController<___VARIABLE_name___ViewModel, ___VARIABLE_name___Router> {

    // MARK: - UI
    private lazy var textField: FormTextField = {
        FormTextField(title: "Title", placeholder: "Placeholder")
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
            self?.viewModel?.save()
        }

        viewModel?.validationDidChange = { [weak self] in
            guard let self else { return }
            self.updateSaveButton(enabled: self.viewModel?.isSaveEnabled ?? false)
        }

        viewModel?.onSaveSuccess = { [weak self] in
            self?.dismiss(animated: true)
        }

        textField.onTextChange = { [weak self] text in
            self?.viewModel?.text = text
        }
    }

    // MARK: - Private
    private func setupForm() {
        addFormItem(textField)
    }
}
