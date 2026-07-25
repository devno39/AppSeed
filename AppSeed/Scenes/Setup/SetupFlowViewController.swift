//
//  SetupFlowViewController.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class SetupFlowViewController: FormBottomSheetViewController<SetupFlowViewModel, SetupFlowRouter> {

    // MARK: - UI
    private lazy var nameField: FormTextField = {
        FormTextField(
            title: SetupLocalizable.name_label,
            placeholder: SetupLocalizable.name_placeholder
        )
    }()

    private lazy var birthDateField: FormDatePickerField = {
        FormDatePickerField(
            title: SetupLocalizable.birthday_label,
            placeholder: SetupLocalizable.birthday_placeholder
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
            guard let self, let viewModel = self.viewModel else { return }
            viewModel.saveProfile()
            UserDefaultsWrapper.has_completed_setup = true
            self.dismiss(animated: true) {
                viewModel.onComplete?()
            }
        }

        viewModel?.validationDidChange = { [weak self] in
            guard let self else { return }
            self.updateSaveButton(enabled: self.viewModel?.isSaveEnabled ?? false)
        }

        nameField.onTextChange = { [weak self] text in
            self?.viewModel?.displayName = text
        }

        birthDateField.onDateChange = { [weak self] date in
            self?.viewModel?.birthDate = date
        }

        prefillData()
    }

    // MARK: - Private
    private func setupForm() {
        addFormItem(nameField)
        addFormItem(birthDateField)
    }

    private func prefillData() {
        let user = UserSessionManager.shared.currentUser
        let name = user?.displayName ?? ""
        if !name.isEmpty {
            nameField.setText(name)
            viewModel?.displayName = name
        }
        if let birthDate = user?.birthDate {
            birthDateField.setDate(birthDate)
            viewModel?.birthDate = birthDate
        }
        updateSaveButton(enabled: viewModel?.isSaveEnabled ?? false)
    }
}
