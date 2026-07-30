//
//  CollectionExtensionTests.swift
//  AppSeedTests
//
//  Created by Claude on 29.07.2026.
//

import XCTest
@testable import AppSeed

final class CollectionExtensionTests: XCTestCase {

    // MARK: - Safe Subscript
    func testSafeSubscriptReturnsElementInRange() {
        XCTAssertEqual([10, 20, 30][safe: 1], 20)
    }

    func testSafeSubscriptReturnsNilOutOfRange() {
        let values = [10, 20, 30]

        XCTAssertNil(values[safe: 3])
        XCTAssertNil(values[safe: -1])
        XCTAssertNil([Int]()[safe: 0])
    }

    // MARK: - isNotEmpty
    func testIsNotEmptyOnOptionalCollections() {
        let filled: [Int]? = [1]
        let empty: [Int]? = []
        let missing: [Int]? = nil

        XCTAssertTrue(filled.isNotEmpty)
        XCTAssertFalse(empty.isNotEmpty)
        XCTAssertFalse(missing.isNotEmpty)
    }
}
