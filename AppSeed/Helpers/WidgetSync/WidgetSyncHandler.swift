//
//  WidgetSyncHandler.swift
//  AppSeed
//
//  Created by Claude on 26.07.2026.
//

import Foundation

enum SyncReason {
    case foregroundFetch      // VM initial data load
    case foregroundRealtime   // Supabase realtime listener fired while app is foreground
    case silentPush           // APNs silent push (content-available: 1)
    case visiblePush          // Notification Service Extension handler
    case manual               // sceneDidBecomeActive reconcile or ad-hoc refresh
}

enum SyncResult {
    case success
    case partial(Error)
    case failure(Error)
    case skipped(reason: String)
}

// Per-widget handler — implementations in Helpers/WidgetSync/Handlers/<Kind>SyncHandler.swift; register via WidgetSyncService.
protocol WidgetSyncHandler {
    static var kind: WidgetSyncKind { get }

    // <3s parallel; ≥3s gets an explicit timeout so push handlers stay inside iOS's 25s budget.
    static var estimatedDuration: TimeInterval { get }

    // Perform the sync: build metadata → write AppGroup → request
    // WidgetCenter reload. Completion fires exactly once.
    static func sync(
        context: WidgetSyncContext,
        timeout: TimeInterval?,
        completion: @escaping (SyncResult) -> Void
    )
}
