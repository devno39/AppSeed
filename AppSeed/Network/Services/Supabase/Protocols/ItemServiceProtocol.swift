//
//  ItemServiceProtocol.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import Foundation

protocol ItemServiceProtocol {

    // MARK: - Read
    func getItems(userId: String, completion: @escaping AnyClosure<[ItemModel]>)
    func listenItems(userId: String, completion: @escaping AnyClosure<[ItemModel]>) -> ListenerHandle

    // MARK: - Write
    func saveItem(_ item: ItemModel, completion: AnyClosure<Error?>?)
    func deleteItem(id: String, completion: AnyClosure<Error?>?)
}
