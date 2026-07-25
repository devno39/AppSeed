//
//  ListenerHandle.swift
//  AppSeed
//
//  Created by Claude on 17.03.2026.
//

import Foundation

final class ListenerHandle {
    private let onRemove: EmptyClosure

    init(_ onRemove: @escaping EmptyClosure) {
        self.onRemove = onRemove
    }

    func remove() {
        onRemove()
    }
}
