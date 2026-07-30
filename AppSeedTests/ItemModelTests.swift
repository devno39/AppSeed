//
//  ItemModelTests.swift
//  AppSeedTests
//
//  Created by Claude on 29.07.2026.
//

import XCTest
@testable import AppSeed

final class ItemModelTests: XCTestCase {

    // MARK: - Decode
    // Locks the snake_case column mapping: a rename on either side breaks this first.
    func testDecodesPostgresColumnNames() throws {
        let json = """
        {
            "id": "11111111-1111-1111-1111-111111111111",
            "user_id": "22222222-2222-2222-2222-222222222222",
            "title": "Buy milk",
            "note": null,
            "emoji": "🥛",
            "is_done": true,
            "created_at": 0,
            "updated_at": 0
        }
        """.data(using: .utf8)!

        let item = try JSONDecoder().decode(ItemModel.self, from: json)

        XCTAssertEqual(item.userId, "22222222-2222-2222-2222-222222222222")
        XCTAssertEqual(item.title, "Buy milk")
        XCTAssertEqual(item.emoji, "🥛")
        XCTAssertTrue(item.isDone)
        XCTAssertNil(item.note)
    }

    func testEncodesBackToPostgresColumnNames() throws {
        let item = ItemModel(userId: "u", title: "t", note: "n", emoji: "🎯")

        let data = try JSONEncoder().encode(item)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertNotNil(object["user_id"])
        XCTAssertNotNil(object["is_done"])
        XCTAssertNotNil(object["created_at"])
        XCTAssertNil(object["userId"])
    }

    // MARK: - Defaults
    func testNewItemStartsUndoneWithALowercasedId() {
        let item = ItemModel(userId: "u", title: "t")

        XCTAssertFalse(item.isDone)
        XCTAssertEqual(item.id, item.id.lowercased())
        XCTAssertNil(item.note)
    }
}
