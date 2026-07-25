//
//  HapticHelper.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// One place for tactile feedback so call sites don't spin up raw generators inline.
enum HapticHelper {

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
