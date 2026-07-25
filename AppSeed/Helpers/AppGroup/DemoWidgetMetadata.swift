//
//  DemoWidgetMetadata.swift
//  AppSeed
//
//  Created by Claude on 26.07.2026.
//

import Foundation

// The 3-field header convention every widget metadata struct opens with
// (scopeId / sessionNonce / updatedAt), then the widget's own payload.
struct DemoWidgetMetadata: Codable {
    let scopeId: String
    let sessionNonce: String
    let updatedAt: Date

    let message: String
}
