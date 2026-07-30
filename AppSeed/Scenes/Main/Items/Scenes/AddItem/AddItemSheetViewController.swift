//
//  AddItemSheetViewController.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import UIKit

final class AddItemSheetViewController: FormBottomSheetViewController<AddItemSheetViewModel, AddItemSheetRouter> {

    // MARK: - UI
    private lazy var titleField: FormTextField = {
        FormTextField(
            title: ItemsLocalizable.add_name,
            placeholder: ItemsLocalizable.add_name_placeholder
        )
    }()

    private lazy var emojiField: FormEmojiField = {
        FormEmojiField(title: ItemsLocalizable.add_emoji)
    }()

    private lazy var noteField: FormTextView = {
        FormTextView(
            title: ItemsLocalizable.add_note,
            placeholder: ItemsLocalizable.add_note_placeholder
        )
    }()

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        addFormItem(titleField)
        addFormItem(emojiField)
        addFormItem(noteField)
        updateSaveButton(enabled: false)
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()

        viewModel?.onSave = { [weak self] in
            guard let self, let viewModel = self.viewModel else { return }
            let model = viewModel.buildModel()
            self.dismiss(animated: true) {
                viewModel.onSubmit?(model)
            }
        }

        viewModel?.validationDidChange = { [weak self] in
            guard let self else { return }
            self.updateSaveButton(enabled: self.viewModel?.isSaveEnabled ?? false)
        }

        titleField.onTextChange = { [weak self] text in
            self?.viewModel?.title = text
        }

        emojiField.onEmojiChange = { [weak self] emoji in
            self?.viewModel?.emoji = emoji
        }

        noteField.onTextChange = { [weak self] text in
            self?.viewModel?.note = text
        }
    }
}
