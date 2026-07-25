//
//  AppSeedWidgetsBundle.swift
//  AppSeedWidgets
//
//  Created by Claude on 25.07.2026.
//

import WidgetKit
import SwiftUI

// Declaration order = Apple widget gallery order. New app copies this seed and
// appends its own widgets here; each widget's `kind` string must match the
// WidgetSyncKind raw value the app reloads.
@main
struct AppSeedWidgetsBundle: WidgetBundle {
    var body: some Widget {
        DemoWidget()
    }
}
