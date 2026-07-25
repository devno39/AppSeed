//
//  WidgetSyncContext.swift
//  AppSeed
//
//  Created by Claude on 26.07.2026.
//

import Foundation

// Immutable snapshot per sync; scopeId + sessionNonce pre-computed for consistency under concurrent calls.
struct WidgetSyncContext {
    let scopeId: String
    let sessionNonce: String
    let language: String
    let theme: String
    // Placeholder in the seed — wire to the real premium state to gate locked widgets.
    let isPro: Bool
    let reason: SyncReason
}
