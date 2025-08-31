//
//  Collection+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 31.08.2025.
//

public extension Collection {
    var isNotEmpty: Bool { !isEmpty }
}

// MARK: - Optional koleksiyonlar için
public extension Optional where Wrapped: Collection {
    var isEmpty: Bool { self?.isEmpty ?? true }
    var isNotEmpty: Bool { !(self?.isEmpty ?? false) }
}
