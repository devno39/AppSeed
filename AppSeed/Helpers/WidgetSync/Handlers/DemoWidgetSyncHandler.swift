//
//  DemoWidgetSyncHandler.swift
//  AppSeed
//
//  Created by Claude on 26.07.2026.
//

import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

// Reference handler: builds a tiny DemoWidgetMetadata from the sync context,
// writes it into the App Group, then reloads the demo widget's timeline.
// Copy this shape for a real widget kind.
enum DemoWidgetSyncHandler: WidgetSyncHandler {
    static var kind: WidgetSyncKind { .demo }
    static var estimatedDuration: TimeInterval { 1 }

    static func sync(
        context: WidgetSyncContext,
        timeout: TimeInterval?,
        completion: @escaping (SyncResult) -> Void
    ) {
        let metadata = DemoWidgetMetadata(
            scopeId: context.scopeId,
            sessionNonce: context.sessionNonce,
            updatedAt: Date(),
            message: "Synced from AppSeed"
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let jsonData = try? encoder.encode(metadata) else {
            completion(.failure(NSError(domain: "DemoWidgetSyncHandler", code: 1)))
            return
        }

        AppGroupStorage.write(kind: .demo, jsonData: jsonData, imageData: nil, scopeId: context.scopeId, sessionNonce: context.sessionNonce) {
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetSyncKind.demo.rawValue)
            #endif
            completion(.success)
        }
    }
}
