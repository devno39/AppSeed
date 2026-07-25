//
//  DemoWidget.swift
//  AppSeedWidgets
//
//  Created by Claude on 26.07.2026.
//

import WidgetKit
import SwiftUI

// Reference widget: reads a DemoWidgetMetadata snapshot the app wrote into the
// App Group (scope + freshness guarded via WidgetSnapshot.read), renders an
// empty state when there is none. Copy this shape for a real widget.

// MARK: - State

enum DemoWidgetState {
    case fresh(DemoWidgetMetadata)
    case empty
}

// MARK: - Entry

struct DemoEntry: TimelineEntry {
    let date: Date
    let state: DemoWidgetState
}

// MARK: - Provider

struct DemoProvider: TimelineProvider {

    func placeholder(in context: Context) -> DemoEntry {
        DemoEntry(date: .now, state: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (DemoEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DemoEntry>) -> Void) {
        let entry = loadEntry()
        completion(Timeline(entries: [entry], policy: .after(WidgetRefresh.next24h)))
    }

    private func loadEntry() -> DemoEntry {
        guard let metadata: DemoWidgetMetadata = WidgetSnapshot.read(.demo) else {
            return DemoEntry(date: .now, state: .empty)
        }
        return DemoEntry(date: .now, state: .fresh(metadata))
    }
}

// MARK: - View

struct DemoWidgetView: View {
    let entry: DemoEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch entry.state {
            case .fresh(let metadata):
                switch family {
                case .systemSmall: smallView(metadata)
                default:           mediumView(metadata)
                }
            case .empty:
                emptyView
            }
        }
        .containerBackground(for: .widget) { WidgetColors.backgroundSecondary }
        .widgetURL(URL(string: "appseed://home"))
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 28))
                .foregroundStyle(WidgetTheme.accentColor)
            Text(WidgetLocalizable.demoEmpty)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(WidgetColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Small

    private func smallView(_ m: DemoWidgetMetadata) -> some View {
        VStack(spacing: 6) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 24))
                .foregroundStyle(WidgetTheme.accentColor)
            Text(WidgetLocalizable.demoTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WidgetColors.textPrimary)
            Text(m.message)
                .font(.system(size: 11))
                .foregroundStyle(WidgetColors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Medium

    private func mediumView(_ m: DemoWidgetMetadata) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(WidgetTheme.accentColor)
                Text(WidgetLocalizable.demoTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WidgetColors.textPrimary)
            }

            // Status bubble (mirrors the in-app status bubble) carrying the snapshot message.
            Text(m.message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(WidgetColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .padding(.top, StatusBubbleShape.tailHeight + 6)
                .padding(.bottom, 6)
                .background(
                    StatusBubbleShape()
                        .fill(WidgetColors.backgroundTertiary)
                        .overlay(StatusBubbleShape().stroke(WidgetColors.backgroundBorder, lineWidth: 0.5))
                )

            Text(WidgetDateFormat.string(m.updatedAt, format: "d MMM HH:mm"))
                .font(.system(size: 10))
                .foregroundStyle(WidgetColors.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Status Bubble Shape

// Pill body + an up tail at the horizontal center, one continuous path.
struct StatusBubbleShape: Shape {

    static let tailHeight: CGFloat = 5
    static let tailWidth: CGFloat = 10

    func path(in rect: CGRect) -> Path {
        let bodyTop = Self.tailHeight
        let bodyBottom = rect.height
        let r = (bodyBottom - bodyTop) / 2
        let cx = rect.midX

        var path = Path()
        path.move(to: CGPoint(x: r, y: bodyTop))
        path.addLine(to: CGPoint(x: cx - Self.tailWidth / 2, y: bodyTop))
        path.addLine(to: CGPoint(x: cx, y: 0))
        path.addLine(to: CGPoint(x: cx + Self.tailWidth / 2, y: bodyTop))
        path.addLine(to: CGPoint(x: rect.width - r, y: bodyTop))
        path.addArc(center: CGPoint(x: rect.width - r, y: bodyTop + r), radius: r, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: r, y: bodyBottom))
        path.addArc(center: CGPoint(x: r, y: bodyTop + r), radius: r, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Widget

struct DemoWidget: Widget {
    let kind = "DemoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DemoProvider()) { entry in
            DemoWidgetView(entry: entry)
        }
        .configurationDisplayName(WidgetLocalizable.demoTitle)
        .description(WidgetLocalizable.demoEmpty)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
