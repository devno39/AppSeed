//
//  DemoWidget.swift
//  AppSeedWidgets
//
//  Created by Claude on 25.07.2026.
//

import WidgetKit
import SwiftUI

// Placeholder demo widget — upgraded into a snapshot-reading widget once the
// App Group + WidgetSync layers land.

// MARK: - Entry

struct DemoEntry: TimelineEntry {
    let date: Date
}

// MARK: - Provider

struct DemoProvider: TimelineProvider {
    func placeholder(in context: Context) -> DemoEntry {
        DemoEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (DemoEntry) -> Void) {
        completion(DemoEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DemoEntry>) -> Void) {
        completion(Timeline(entries: [DemoEntry(date: .now)], policy: .never))
    }
}

// MARK: - View

struct DemoWidgetView: View {
    let entry: DemoEntry

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 28))
            Text("AppSeed")
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { Color.white }
    }
}

// MARK: - Widget

struct DemoWidget: Widget {
    let kind = "DemoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DemoProvider()) { entry in
            DemoWidgetView(entry: entry)
        }
        .configurationDisplayName("Demo")
        .description("AppSeed demo widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
