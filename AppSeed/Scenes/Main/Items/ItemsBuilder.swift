//
//  ItemsBuilder.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import UIKit

final class ItemsBuilder: BaseBuilder {

    // MARK: - Build
    func build() -> UIViewController {
        let router = ItemsRouter()
        let viewModel = ItemsViewModel(itemService: SupabaseItemService())

        return ItemsViewController(viewModel: viewModel, router: router)
    }
}
