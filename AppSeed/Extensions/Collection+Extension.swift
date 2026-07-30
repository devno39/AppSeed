//
//  Collection+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 31.08.2025.
//

public extension Collection {
    var isNotEmpty: Bool { !isEmpty }

    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Optional koleksiyonlar için
public extension Optional where Wrapped: Collection {
    var isEmpty: Bool { self?.isEmpty ?? true }
    var isNotEmpty: Bool { !isEmpty }
}
