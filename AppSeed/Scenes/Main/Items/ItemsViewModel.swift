//
//  ItemsViewModel.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import Foundation

// MARK: - Source
protocol ItemsViewModelDataSource {
    var items: [ItemModel] { get }
    var isEmpty: Bool { get }
    func item(at index: Int) -> ItemModel?
}

// MARK: - Closure
protocol ItemsViewModelClosureSource {
    var itemsDidChange: EmptyClosure? { get set }
}

// MARK: - Function
protocol ItemsViewModelFunctionSource {
    func startListening()
    func stopListening()
    func addItem(title: String, note: String?, emoji: String?)
    func updateItem(_ item: ItemModel)
    func toggleDone(at index: Int)
    func deleteItem(at index: Int)
}

// MARK: - Protocol
protocol ItemsViewModelProtocol: BaseViewModelProtocol,
                                 ItemsViewModelDataSource,
                                 ItemsViewModelClosureSource,
                                 ItemsViewModelFunctionSource { }

// MARK: - ViewModel
final class ItemsViewModel: BaseViewModel, ItemsViewModelProtocol {

    // MARK: - Source
    private(set) var items: [ItemModel] = [] {
        didSet { itemsDidChange?() }
    }

    var isEmpty: Bool { items.isEmpty }

    // MARK: - Services
    private let itemService: ItemServiceProtocol

    // MARK: - Closure
    var itemsDidChange: EmptyClosure?

    // MARK: - Properties
    private var listener: ListenerHandle?

    // MARK: - Init
    init(itemService: ItemServiceProtocol) {
        self.itemService = itemService
        super.init()
    }

    // MARK: - DataSource
    func item(at index: Int) -> ItemModel? {
        items[safe: index]
    }

    // MARK: - Fetch
    // The listener delivers the first page too, so there is no separate initial fetch.
    func startListening() {
        guard let userId = UserSessionManager.shared.currentUser?.userId else { return }
        listener?.remove()
        listener = itemService.listenItems(userId: userId) { [weak self] items in
            self?.items = items.sorted { $0.createdAt > $1.createdAt }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Write
    // Every write lands locally first and is reconciled by the listener's refetch. A failed
    // write is rolled back here — the server never saw it, so no echo will correct the UI.
    func addItem(title: String, note: String?, emoji: String?) {
        guard let userId = UserSessionManager.shared.currentUser?.userId else { return }

        let item = ItemModel(userId: userId, title: title, note: note, emoji: emoji)
        items.insert(item, at: 0)

        itemService.saveItem(item) { [weak self] error in
            guard error != nil else { return }
            self?.items.removeAll { $0.id == item.id }
        }
    }

    func updateItem(_ item: ItemModel) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        let previous = items[index]
        items[index] = item

        itemService.saveItem(item) { [weak self] error in
            guard error != nil, let self, let index = self.items.firstIndex(where: { $0.id == item.id }) else { return }
            self.items[index] = previous
        }
    }

    func toggleDone(at index: Int) {
        guard var item = items[safe: index] else { return }
        item.isDone.toggle()
        updateItem(item)
    }

    func deleteItem(at index: Int) {
        guard let item = items[safe: index] else { return }
        items.remove(at: index)

        itemService.deleteItem(id: item.id) { [weak self] error in
            guard error != nil else { return }
            self?.items.insert(item, at: min(index, self?.items.count ?? 0))
        }
    }
}
