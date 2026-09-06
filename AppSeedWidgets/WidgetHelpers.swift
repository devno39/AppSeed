//
//  WidgetHelpers.swift
//  AppSeedWidgets
//
//  Created by Claude on 26.07.2026.
//

import SwiftUI
import UIKit
import WidgetKit

// MARK: - Gradient Fill
// UIKit-side gradient-on-alpha-mask helper, for widgets that composite a
// template image into a bitmap (e.g. map pins). Renders at `maxSide` preserving
// aspect so a large PDF asset doesn't blow WidgetKit's ~2.3MP archive budget.
// SwiftUI widgets should use `.mask` + LinearGradient instead of this helper.

extension UIImage {

    func withWidgetGradient(top: UIColor, bottom: UIColor, maxSide: CGFloat) -> UIImage {
        let aspect = size.width / max(size.height, 1)
        let renderSize = aspect >= 1
            ? CGSize(width: maxSide, height: maxSide / aspect)
            : CGSize(width: maxSide * aspect, height: maxSide)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 2
        let renderer = UIGraphicsImageRenderer(size: renderSize, format: format)
        let rect = CGRect(origin: .zero, size: renderSize)

        let mask = renderer.image { _ in draw(in: rect) }

        return renderer.image { ctx in
            let colors = [top.cgColor, bottom.cgColor] as CFArray
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 1]
            ) else { return }
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: rect.midX, y: 0),
                end: CGPoint(x: rect.midX, y: rect.height),
                options: []
            )
            mask.draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        }
    }
}

// MARK: - Widget Background

extension View {

    func widgetBackground() -> some View {
        self.containerBackground(for: .widget) {
            WidgetColors.backgroundSecondary
        }
    }

    func widgetBackgroundImage(_ image: Image) -> some View {
        self.containerBackground(for: .widget) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}

// MARK: - Timeline Refresh
// Main app drives fast refreshes via WidgetCenter.reloadTimelines(ofKind:).
// 24h safety net ensures the widget self-heals if the main app is killed and
// never reopened (compromise between .never and .after(6h)).
enum WidgetRefresh {
    static var next24h: Date {
        Calendar.current.date(byAdding: .hour, value: 24, to: .now) ?? .now
    }

    // Date-countdown widgets must roll at local midnight, not 24h after
    // the last reload — otherwise the displayed day count stays stale
    // for up to a day after rollover.
    static var nextMidnight: Date {
        Calendar.current.nextDate(
            after: .now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? next24h
    }
}

// MARK: - Widget Locale

enum WidgetLocale {
    static var current: Locale {
        Locale(identifier: AppGroupStorage.selectedLanguage ?? "en")
    }
}

// MARK: - Date Format

enum WidgetDateFormat {
    static func string(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = WidgetLocale.current
        formatter.dateFormat = format
        return formatter.string(from: date).capitalized(with: formatter.locale)
    }
}

// MARK: - Number Format

enum WidgetNumberFormat {
    static func grouped(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = WidgetLocale.current
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - Snapshot Read

enum WidgetSnapshot {
    static func read<T: Decodable>(_ kind: AppGroupStorage.WidgetKind) -> T? {
        guard AppGroupStorage.currentScopeId != nil,
              case .fresh(_, let jsonData) = AppGroupStorage.read(kind: kind, expectedSessionNonce: nil) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(T.self, from: jsonData)
    }
}

// MARK: - Snapshot Age

// Snapshot values freeze at sync time — count widgets roll them forward by the days since the write.
enum SnapshotAge {
    static func days(since date: Date) -> Int {
        let calendar = Calendar.current
        let from = calendar.startOfDay(for: date)
        let to = calendar.startOfDay(for: .now)
        return max(0, calendar.dateComponents([.day], from: from, to: to).day ?? 0)
    }
}

// MARK: - String

extension String {
    var initialLetter: String {
        first.map { String($0).uppercased() } ?? "•"
    }
}

// MARK: - Pro Stamp View
// SwiftUI twin of the app's ProBadgeView.
struct ProStampView: View {

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown")
                .font(.system(size: 11, weight: .heavy))

            Text(WidgetLocalizable.pro)
                .font(.system(size: 11, weight: .heavy))
        }
        .foregroundStyle(WidgetTheme.accentColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(WidgetTheme.accentColor, lineWidth: 2)
        )
        .rotationEffect(.degrees(-18))
    }
}

// MARK: - Locked Home Widget View
// Rendered by premium widgets when AppGroupStorage.isPro is false; pair with `.widgetURL(appseed://paywall)`.
struct LockedHomeWidgetView: View {

    var body: some View {
        VStack(spacing: 10) {
            ProStampView()

            Text(WidgetLocalizable.tapToUnlock)
                .font(.caption2)
                .foregroundStyle(WidgetColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            WidgetColors.backgroundSecondary
        }
    }
}

// MARK: - Locked Accessory Widget View
// Lock screen counterpart — accessory slots render vibrant monochrome, so no WidgetColors here.
struct LockedAccessoryWidgetView: View {
    @Environment(\.widgetFamily) var family

    var body: some View {
        if family == .accessoryRectangular {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16, weight: .medium))
                VStack(alignment: .leading, spacing: 0) {
                    Text(WidgetLocalizable.pro)
                        .font(.system(size: 12, weight: .semibold))
                    Text(WidgetLocalizable.tapToUnlock)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            VStack(spacing: 1) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .medium))
                Text(WidgetLocalizable.pro)
                    .font(.system(size: 7, weight: .semibold))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .padding(4)
        }
    }
}
