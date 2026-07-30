//
//  SupabaseItemService.swift
//  AppSeed
//
//  Created by Claude on 29.07.2026.
//

import Foundation
import Supabase

final class SupabaseItemService: ItemServiceProtocol {

    // MARK: - Client
    private var client: SupabaseClient { SupabaseManager.shared.client }

    // MARK: - Read
    func getItems(userId: String, completion: @escaping AnyClosure<[ItemModel]>) {
        SupabaseDatabaseHelper.getList(
            .items,
            filterColumn: "user_id",
            filterValue: userId,
            as: ItemModel.self,
            completion: completion
        )
    }

    // A collection listener refetches on every event instead of applying the row delta:
    // inserts, updates and deletes would each need their own merge, and the list is small.
    // Decode the record (SupabaseRealtimeDecoder) instead once a table grows past that.
    func listenItems(userId: String, completion: @escaping AnyClosure<[ItemModel]>) -> ListenerHandle {
        let channel = client.realtimeV2.channel("items-\(UUID().uuidString.prefix(8))")

        let onChange = channel.postgresChange(
            AnyAction.self,
            table: "items",
            filter: .eq("user_id", value: userId)
        )

        Task { [weak self] in
            do {
                try await channel.subscribeWithError()
                log(.success, .supabase, "Realtime subscribed: items")
            } catch {
                log(.error, .supabase, "Realtime subscribe failed: items - \(error.localizedDescription)")
            }

            self?.getItems(userId: userId, completion: completion)

            for await _ in onChange {
                self?.getItems(userId: userId, completion: completion)
            }
        }

        return ListenerHandle {
            Task { await channel.unsubscribe() }
        }
    }

    // MARK: - Write
    func saveItem(_ item: ItemModel, completion: AnyClosure<Error?>?) {
        SupabaseDatabaseHelper.upsert(.items, object: item, completion: completion)
    }

    func deleteItem(id: String, completion: AnyClosure<Error?>?) {
        SupabaseDatabaseHelper.delete(.items, id: id, completion: completion)
    }
}
