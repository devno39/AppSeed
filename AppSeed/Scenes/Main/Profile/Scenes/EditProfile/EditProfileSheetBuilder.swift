//
//  EditProfileSheetBuilder.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

final class EditProfileSheetBuilder: BaseBuilder {

    // MARK: - Properties
    private let displayName: String?
    private let imageURL: String?
    private let birthDate: Date?
    private let onSave: AnyClosure<EditProfileModel>?

    // MARK: - Init
    init(
        displayName: String? = nil,
        imageURL: String? = nil,
        birthDate: Date? = nil,
        onSave: AnyClosure<EditProfileModel>? = nil
    ) {
        self.displayName = displayName
        self.imageURL = imageURL
        self.birthDate = birthDate
        self.onSave = onSave
    }

    // MARK: - Build
    func build() -> UIViewController {
        let router = EditProfileSheetRouter()
        let viewModel = EditProfileSheetViewModel()
        viewModel.sheetTitle = ProfileLocalizable.edit_title
        viewModel.saveTitle = ProfileLocalizable.edit_save
        viewModel.displayName = displayName ?? ""
        viewModel.existingImageUrl = imageURL
        viewModel.birthDate = birthDate
        viewModel.onSaveProfile = onSave

        let viewController = EditProfileSheetViewController(viewModel: viewModel, router: router)
        return viewController
    }
}
