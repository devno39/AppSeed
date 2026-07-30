//
//  SupabaseDatabaseHelper.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import Foundation
import Supabase

struct SupabaseDatabaseHelper {

    // MARK: - Client
    private static var client: SupabaseClient {
        SupabaseManager.shared.client
    }

    // MARK: - Error Handling
    static var errorHandler: AnyClosure<Error>?

    // MARK: - Tables
    enum Table: String {
        case users
        case items
        case deviceTokens = "device_tokens"
    }

    // MARK: - Insert / Upsert (Encodable)
    static func upsert<T: Encodable>(
        _ table: Table,
        object: T,
        completion: AnyClosure<Error?>? = nil
    ) {
        Task {
            do {
                try await client.from(table.rawValue)
                    .upsert(object)
                    .execute()

                await MainActor.run { completion?(nil) }
            } catch {
                log(.error, .supabase, decodingDetail(error))
                await MainActor.run {
                    errorHandler?(error)
                    completion?(error)
                }
            }
        }
    }

    // MARK: - Insert / Upsert (Raw)
    static func upsert(
        _ table: Table,
        data: [String: AnyJSON],
        completion: AnyClosure<Error?>? = nil
    ) {
        Task {
            do {
                try await client.from(table.rawValue)
                    .upsert(data)
                    .execute()

                await MainActor.run { completion?(nil) }
            } catch {
                log(.error, .supabase, decodingDetail(error))
                await MainActor.run {
                    errorHandler?(error)
                    completion?(error)
                }
            }
        }
    }

    // MARK: - Read (Decodable)
    static func get<T: Decodable>(
        _ table: Table,
        id: String,
        idColumn: String = "id",
        as type: T.Type,
        completion: @escaping AnyClosure<T?>
    ) {
        Task {
            do {
                let result: T = try await client.from(table.rawValue)
                    .select()
                    .eq(idColumn, value: id)
                    .single()
                    .execute()
                    .value

                await MainActor.run { completion(result) }
            } catch {
                log(.error, .supabase, decodingDetail(error))
                await MainActor.run {
                    errorHandler?(error)
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Read List (Decodable)
    static func getList<T: Decodable>(
        _ table: Table,
        filterColumn: String,
        filterValue: String,
        as type: T.Type,
        completion: @escaping AnyClosure<[T]>
    ) {
        Task {
            do {
                let result: [T] = try await client.from(table.rawValue)
                    .select()
                    .eq(filterColumn, value: filterValue)
                    .execute()
                    .value

                await MainActor.run { completion(result) }
            } catch {
                log(.error, .supabase, decodingDetail(error))
                await MainActor.run {
                    errorHandler?(error)
                    completion([])
                }
            }
        }
    }

    // MARK: - Read (Result)
    // Failure ≠ absence: .success(nil) = row does not exist, .failure = transient error (network, decode).
    static func getResult<T: Decodable>(
        _ table: Table,
        id: String,
        idColumn: String = "id",
        as type: T.Type,
        completion: @escaping AnyClosure<Result<T?, Error>>
    ) {
        Task {
            do {
                let result: [T] = try await client.from(table.rawValue)
                    .select()
                    .eq(idColumn, value: id)
                    .limit(1)
                    .execute()
                    .value

                await MainActor.run { completion(.success(result.first)) }
            } catch {
                log(.error, .supabase, decodingDetail(error))
                await MainActor.run {
                    errorHandler?(error)
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Read List (Result)
    static func getListResult<T: Decodable>(
        _ table: Table,
        filterColumn: String,
        filterValue: String,
        as type: T.Type,
        completion: @escaping AnyClosure<Result<[T], Error>>
    ) {
        Task {
            do {
                let result: [T] = try await client.from(table.rawValue)
                    .select()
                    .eq(filterColumn, value: filterValue)
                    .execute()
                    .value

                await MainActor.run { completion(.success(result)) }
            } catch {
                log(.error, .supabase, decodingDetail(error))
                await MainActor.run {
                    errorHandler?(error)
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Update
    static func update(
        _ table: Table,
        id: String,
        idColumn: String = "id",
        fields: [String: AnyJSON],
        completion: AnyClosure<Error?>? = nil
    ) {
        Task {
            do {
                try await client.from(table.rawValue)
                    .update(fields)
                    .eq(idColumn, value: id)
                    .execute()

                await MainActor.run { completion?(nil) }
            } catch {
                log(.error, .supabase, decodingDetail(error))
                await MainActor.run {
                    errorHandler?(error)
                    completion?(error)
                }
            }
        }
    }

    // MARK: - Decoding Detail
    private static func decodingDetail(_ error: Error) -> String {
        guard let decoding = error as? DecodingError else {
            return error.localizedDescription
        }
        switch decoding {
        case .keyNotFound(let key, let ctx):
            return "keyNotFound: \(key.stringValue) at \(ctx.codingPath.map { $0.stringValue }.joined(separator: ".")) — \(ctx.debugDescription)"
        case .typeMismatch(let type, let ctx):
            return "typeMismatch: expected \(type) at \(ctx.codingPath.map { $0.stringValue }.joined(separator: ".")) — \(ctx.debugDescription)"
        case .valueNotFound(let type, let ctx):
            return "valueNotFound: \(type) at \(ctx.codingPath.map { $0.stringValue }.joined(separator: ".")) — \(ctx.debugDescription)"
        case .dataCorrupted(let ctx):
            return "dataCorrupted at \(ctx.codingPath.map { $0.stringValue }.joined(separator: ".")) — \(ctx.debugDescription)"
        @unknown default:
            return "unknown decoding error: \(error)"
        }
    }

    // MARK: - Delete
    static func delete(
        _ table: Table,
        id: String,
        idColumn: String = "id",
        completion: AnyClosure<Error?>? = nil
    ) {
        Task {
            do {
                try await client.from(table.rawValue)
                    .delete()
                    .eq(idColumn, value: id)
                    .execute()

                await MainActor.run { completion?(nil) }
            } catch {
                log(.error, .supabase, decodingDetail(error))
                await MainActor.run {
                    errorHandler?(error)
                    completion?(error)
                }
            }
        }
    }
}
