//
//  AppGroupStorage.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import Foundation
import UIKit

// Shared App Group container: the app writes widget snapshots here, the widget
// extension reads them (widgets can't do realtime). Snapshots are vintage-UUID
// atomic writes with a pointer file, validated at read time against the current
// user-scope + session nonce + freshness TTL.
enum AppGroupStorage {

    // MARK: - Widget Kinds

    // One kind per widget snapshot family. The next app adds cases here.
    enum WidgetKind: String, CaseIterable {
        case demo

        var filePrefix: String { "widget" }
    }

    // MARK: - Configuration

    // Single source of truth for the App Group id (both app and widget layers
    // reference this — AppGroupStorage compiles into both targets).
    static let groupIdentifier = "group.com.devno39.appseed"
    static let thumbnailTargetSize = CGSize(width: 600, height: 600)
    static let freshnessTTL: TimeInterval = 7 * 24 * 3600

    // MARK: - Properties

    private static let writeQueue = DispatchQueue(label: "com.appseed.appgroup.write")

    // MARK: - Read Result

    enum ReadResult {
        case fresh(UIImage?, Data)
        case neverInitialized
        case sessionExpired
        case stale
        case corrupted
    }

    // MARK: - Shared UserDefaults

    static let sharedDefaults = UserDefaults(suiteName: groupIdentifier)

    private static let languageKey = "selectedLanguage"
    private static let isProKey = "isPro"
    private static let currentScopeIdKey = "currentScopeId"

    static var selectedLanguage: String? {
        get { sharedDefaults?.string(forKey: languageKey) }
        set { sharedDefaults?.set(newValue, forKey: languageKey) }
    }

    // Mirrors the app's premium state so the widget can render a locked
    // placeholder without touching the IAP SDK. Placeholder in the seed.
    static var isPro: Bool {
        get { sharedDefaults?.bool(forKey: isProKey) ?? false }
        set { sharedDefaults?.set(newValue, forKey: isProKey) }
    }

    // Mirrors the current user-scope (e.g. the signed-in user id). Widgets
    // compare at render time to reject stale content after a wipe.
    static var currentScopeId: String? {
        get { sharedDefaults?.string(forKey: currentScopeIdKey) }
        set {
            if let newValue {
                sharedDefaults?.set(newValue, forKey: currentScopeIdKey)
            } else {
                sharedDefaults?.removeObject(forKey: currentScopeIdKey)
            }
        }
    }

    // MARK: - Migration (theme/palette standard → shared)
    // Pre-existing UserDefaults.standard values move into the AppGroup suite so widgets can read them. Runs once per install.
    static func migrateThemePaletteToSharedDefaultsIfNeeded() {
        guard let shared = sharedDefaults else { return }
        let migrationFlag = "migrated_theme_palette_v1"
        guard !shared.bool(forKey: migrationFlag) else { return }

        let standard = UserDefaults.standard
        for key in ["selected_theme", "selected_palette", "custom_palette_hex"] {
            if shared.object(forKey: key) == nil,
               let value = standard.object(forKey: key) {
                shared.set(value, forKey: key)
            }
        }
        shared.set(true, forKey: migrationFlag)
    }

    // MARK: - URLs

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
    }

    static func directory(for kind: WidgetKind) -> URL? {
        containerURL?.appendingPathComponent(kind.rawValue, isDirectory: true)
    }

    // Avatar files live outside the per-widget vintage directories — they're
    // tied to user identity, not widget state. Widget reads via UIImage(contentsOfFile:).
    static var avatarsDirectory: URL? {
        containerURL?.appendingPathComponent("avatars", isDirectory: true)
    }

    @discardableResult
    static func saveAvatar(data: Data, key: String) -> String? {
        guard let dir = avatarsDirectory else { return nil }
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let url = dir.appendingPathComponent("\(key).png", isDirectory: false)
            try data.write(to: url, options: .atomic)
            excludeFromBackup(url)
            return url.path
        } catch {
            return nil
        }
    }

    static func pointerURL(for kind: WidgetKind) -> URL? {
        directory(for: kind)?.appendingPathComponent("current.txt", isDirectory: false)
    }

    // MARK: - Write

    static func write(kind: WidgetKind, jsonData: Data, imageData: Data?, scopeId: String, sessionNonce: String, completion: (() -> Void)? = nil) {
        writeQueue.async {
            // A sync in flight at logout/scope-change completes after the wipe — drop writes whose scope is gone.
            guard scopeId == currentScopeId, let dir = directory(for: kind) else {
                DispatchQueue.main.async { completion?() }
                return
            }

            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

                let vintageId = UUID().uuidString
                let prefix = kind.filePrefix

                if let imageData {
                    let pngURL = dir.appendingPathComponent("\(prefix)_\(vintageId).png", isDirectory: false)
                    try imageData.write(to: pngURL, options: .atomic)
                    excludeFromBackup(pngURL)
                }

                let jsonURL = dir.appendingPathComponent("\(prefix)_\(vintageId).json", isDirectory: false)
                try jsonData.write(to: jsonURL, options: .atomic)
                excludeFromBackup(jsonURL)

                if let pointer = pointerURL(for: kind),
                   let uuidData = vintageId.data(using: .utf8) {
                    try uuidData.write(to: pointer, options: .atomic)
                    excludeFromBackup(pointer)
                }

                cleanupOldVintages(currentId: vintageId, prefix: prefix, in: dir)
            } catch { debugPrint("AppGroupStorage write failed: \(error)") }

            DispatchQueue.main.async { completion?() }
        }
    }

    // MARK: - Write (Multi-image)

    // Carousel-style snapshots: N pngs + one json under a single vintage.
    static func writeImages(kind: WidgetKind, jsonData: Data, imageDatas: [Data], scopeId: String, sessionNonce: String, completion: (() -> Void)? = nil) {
        writeQueue.async {
            guard scopeId == currentScopeId, let dir = directory(for: kind) else {
                DispatchQueue.main.async { completion?() }
                return
            }

            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

                let vintageId = UUID().uuidString
                let prefix = kind.filePrefix

                for (index, imageData) in imageDatas.enumerated() {
                    let pngURL = dir.appendingPathComponent("\(prefix)_\(vintageId)_\(index).png", isDirectory: false)
                    try imageData.write(to: pngURL, options: .atomic)
                    excludeFromBackup(pngURL)
                }

                let jsonURL = dir.appendingPathComponent("\(prefix)_\(vintageId).json", isDirectory: false)
                try jsonData.write(to: jsonURL, options: .atomic)
                excludeFromBackup(jsonURL)

                if let pointer = pointerURL(for: kind),
                   let uuidData = vintageId.data(using: .utf8) {
                    try uuidData.write(to: pointer, options: .atomic)
                    excludeFromBackup(pointer)
                }

                cleanupOldVintages(currentId: vintageId, prefix: prefix, in: dir)
            } catch { debugPrint("AppGroupStorage writeImages failed: \(error)") }

            DispatchQueue.main.async { completion?() }
        }
    }

    // MARK: - Read (Multi-image)

    enum ImagesReadResult {
        case fresh([UIImage], Data)
        case neverInitialized
        case sessionExpired
        case stale
        case corrupted
    }

    static func readImages(kind: WidgetKind, expectedSessionNonce: String?) -> ImagesReadResult {
        guard let dir = directory(for: kind) else { return .neverInitialized }

        let pointer = dir.appendingPathComponent("current.txt", isDirectory: false)
        guard FileManager.default.fileExists(atPath: pointer.path),
              let pointerData = try? Data(contentsOf: pointer),
              let rawUUID = String(data: pointerData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !rawUUID.isEmpty else {
            return .neverInitialized
        }

        let prefix = kind.filePrefix
        let jsonURL = dir.appendingPathComponent("\(prefix)_\(rawUUID).json", isDirectory: false)

        guard let jsonData = try? Data(contentsOf: jsonURL) else { return .corrupted }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let common = try? decoder.decode(CommonWidgetFields.self, from: jsonData) else {
            return .corrupted
        }

        if let expected = expectedSessionNonce, expected != common.sessionNonce {
            return .sessionExpired
        }

        if let storedScopeId = common.scopeId, storedScopeId != currentScopeId {
            return .sessionExpired
        }

        if Date().timeIntervalSince(common.updatedAt) > freshnessTTL {
            return .stale
        }

        // Enumerate _<index>.png files until the first gap — no imageCount field needed.
        var images: [UIImage] = []
        var index = 0
        while true {
            let pngURL = dir.appendingPathComponent("\(prefix)_\(rawUUID)_\(index).png", isDirectory: false)
            guard let pngData = try? Data(contentsOf: pngURL), let image = UIImage(data: pngData) else { break }
            images.append(image)
            index += 1
        }

        guard !images.isEmpty else { return .corrupted }
        return .fresh(images, jsonData)
    }

    // MARK: - Read

    static func read(kind: WidgetKind, expectedSessionNonce: String?) -> ReadResult {
        guard let dir = directory(for: kind) else { return .neverInitialized }

        let pointer = dir.appendingPathComponent("current.txt", isDirectory: false)
        guard FileManager.default.fileExists(atPath: pointer.path),
              let pointerData = try? Data(contentsOf: pointer),
              let rawUUID = String(data: pointerData, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
              !rawUUID.isEmpty else {
            return .neverInitialized
        }

        let prefix = kind.filePrefix
        let jsonURL = dir.appendingPathComponent("\(prefix)_\(rawUUID).json", isDirectory: false)
        let pngURL = dir.appendingPathComponent("\(prefix)_\(rawUUID).png", isDirectory: false)

        guard let jsonData = try? Data(contentsOf: jsonURL) else { return .corrupted }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let common = try? decoder.decode(CommonWidgetFields.self, from: jsonData) else {
            return .corrupted
        }

        if let expected = expectedSessionNonce, expected != common.sessionNonce {
            return .sessionExpired
        }

        // Render-time scope check — a stale file surviving the wipe must not show ex-scope content.
        if let storedScopeId = common.scopeId, storedScopeId != currentScopeId {
            return .sessionExpired
        }

        if Date().timeIntervalSince(common.updatedAt) > freshnessTTL {
            return .stale
        }

        var image: UIImage?
        if FileManager.default.fileExists(atPath: pngURL.path),
           let pngData = try? Data(contentsOf: pngURL) {
            image = UIImage(data: pngData)
        }

        return .fresh(image, jsonData)
    }

    // MARK: - Wipe

    // Serialized on writeQueue so a wipe can't interleave with an in-flight snapshot write.
    static func wipe() {
        writeQueue.sync {
            guard let container = containerURL else { return }
            for kind in WidgetKind.allCases {
                let dir = container.appendingPathComponent(kind.rawValue, isDirectory: true)
                try? FileManager.default.removeItem(at: dir)
            }
            // Avatars survive widget vintages — purge so ex-scope portraits
            // don't render after sign-out / scope change.
            if let avatars = avatarsDirectory {
                try? FileManager.default.removeItem(at: avatars)
            }
        }
    }

    // MARK: - Helpers

    static func downscale(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        if let thumb = image.preparingThumbnail(of: targetSize) { return thumb }
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private static func excludeFromBackup(_ url: URL) {
        var mutableURL = url
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? mutableURL.setResourceValues(values)
    }

    private static func cleanupOldVintages(currentId: String, prefix: String, in dir: URL) {
        let keepPrefix = "\(prefix)_\(currentId)"
        let contents = (try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? []

        for filename in contents {
            guard filename.hasPrefix("\(prefix)_"),
                  !filename.hasPrefix(keepPrefix),
                  filename != "current.txt" else { continue }
            try? FileManager.default.removeItem(at: dir.appendingPathComponent(filename, isDirectory: false))
        }
    }
}

// MARK: - Common Fields

// The 3-field header every widget metadata struct starts with — decoded for
// scope/session/freshness validation independent of the concrete payload.
private struct CommonWidgetFields: Codable {
    let sessionNonce: String
    let updatedAt: Date
    let scopeId: String?
}
