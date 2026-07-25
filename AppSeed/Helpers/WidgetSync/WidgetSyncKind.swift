//
//  WidgetSyncKind.swift
//  AppSeed
//
//  Created by Claude on 26.07.2026.
//

import Foundation

// Raw value = the WidgetKit kind string passed to WidgetCenter.reloadTimelines(ofKind:); must match each widget's `kind`.
// Distinct from AppGroupStorage.WidgetKind to prevent ambiguous reads at call sites that use both.
enum WidgetSyncKind: String, CaseIterable {
    case demo = "DemoWidget"
}
