//
//  EditProfileSheetViewController.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import PhotosUI

final class EditProfileSheetViewController: FormBottomSheetViewController<EditProfileSheetViewModel, EditProfileSheetRouter> {

    // MARK: - UI
    private lazy var imagePickerField: FormImagePickerField = {
        FormImagePickerField(buttonTitle: ProfileLocalizable.edit_photo, compact: true)
    }()

    private lazy var nameField: FormTextField = {
        FormTextField(
            title: ProfileLocalizable.edit_name,
            placeholder: ProfileLocalizable.edit_name_placeholder
        )
    }()

    private lazy var birthDateField: FormDatePickerField = {
        FormDatePickerField(
            title: ProfileLocalizable.edit_birth_date,
            placeholder: ProfileLocalizable.edit_birth_date_placeholder,
            date: viewModel?.birthDate
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
            if let cropped = self.imagePickerField.croppedImage {
                viewModel.image = cropped
            }
            let model = viewModel.buildModel()
            self.dismiss(animated: true) {
                viewModel.onSaveProfile?(model)
            }
        }

        viewModel?.validationDidChange = { [weak self] in
            guard let self else { return }
            self.updateSaveButton(enabled: self.viewModel?.isSaveEnabled ?? false)
        }

        imagePickerField.onTap = { [weak self] in
            self?.presentPhotoPicker()
        }

        imagePickerField.onUserInteraction = { [weak self] in
            guard let self, let cropped = self.imagePickerField.croppedImage else { return }
            self.viewModel?.image = cropped
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
        addFormItem(imagePickerField)
        addFormItem(nameField)
        addFormItem(birthDateField)
    }

    private func prefillData() {
        if let urlString = viewModel?.existingImageUrl {
            imagePickerField.setImageURL(urlString)
        }

        let name = viewModel?.displayName ?? ""
        if !name.isEmpty {
            nameField.setText(name)
        }

        viewModel?.saveInitialState()
        updateSaveButton(enabled: viewModel?.isSaveEnabled ?? false)
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension EditProfileSheetViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self?.viewModel?.image = image
                self?.imagePickerField.setImage(image)
            }
        }
    }
}
