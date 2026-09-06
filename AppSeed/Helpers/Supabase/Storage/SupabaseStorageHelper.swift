//
//  SupabaseStorageHelper.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import UIKit
import Supabase
import Kingfisher

struct SupabaseStorageHelper {

    // MARK: - Bucket
    private static let bucket = "avatars"

    // MARK: - Upload Caps
    // Resize output is typically ~150KB (memory) / ~400KB (profile PNG); 5MB cap guards against corrupt or oversized originals.
    private static let maxUploadBytes: Int = 5 * 1024 * 1024

    // MARK: - Retry
    private static let maxUploadRetries = 2
    private static let retryDelayNanoseconds: UInt64 = 500_000_000

    // The SDK wraps the URL error, so the chain has to be walked rather than cast.
    private static func isTransient(_ error: Error) -> Bool {
        let retryable: Set<Int> = [
            NSURLErrorNetworkConnectionLost,
            NSURLErrorTimedOut,
            NSURLErrorCannotConnectToHost,
            NSURLErrorDNSLookupFailed
        ]
        var current: NSError? = error as NSError
        while let candidate = current {
            if candidate.domain == NSURLErrorDomain, retryable.contains(candidate.code) { return true }
            current = candidate.userInfo[NSUnderlyingErrorKey] as? NSError
        }
        return false
    }

    // MARK: - Image Format
    enum ImageFormat: CaseIterable {
        case png
        case jpeg

        var fileExtension: String {
            switch self {
            case .png: "png"
            case .jpeg: "jpg"
            }
        }

        var contentType: String {
            switch self {
            case .png: "image/png"
            case .jpeg: "image/jpeg"
            }
        }

        // JPEG = no alpha channel, opaque renderer = ~2x smaller bitmap.
        // PNG keeps alpha for avatar transparency.
        var opaque: Bool {
            switch self {
            case .png: false
            case .jpeg: true
            }
        }

        func encode(_ image: UIImage, compression: CGFloat) -> Data? {
            switch self {
            case .png: image.pngData()
            case .jpeg: image.jpegData(compressionQuality: compression)
            }
        }
    }

    // MARK: - Paths
    enum StoragePath: String {
        case profileImages = "profile_images"

        // Image uploads only — uploadData paths ignore this and send binaries at full size.
        var maxSize: CGFloat {
            switch self {
            case .profileImages: 512
            }
        }

        // Fallback for paths that never carry alpha; the real choice is per image below.
        var imageFormat: ImageFormat {
            switch self {
            case .profileImages: .png
            }
        }

        // A cut-out avatar flattens to white as JPEG; a camera photo forced through PNG at 512px
        // costs ~950kB against ~50kB. Asked of the ORIGINAL image — the resize renderer adds an
        // alpha channel whenever told to.
        func imageFormat(for image: UIImage) -> ImageFormat {
            switch self {
            case .profileImages: image.carriesAlpha ? .png : .jpeg
            }
        }
    }

    // MARK: - Signed URL Resolution
    // Stored URLs carry a 365-day token with no refresh path — reads re-sign the embedded
    // storage path with a fresh 24h token so shown content never expires. Every failure
    // falls back to the stored URL: behavior is never worse than before this layer existed.
    struct ResolvedImage {
        let url: URL
        // Survives token rotation, changes when the stored URL carries a new content version.
        let cacheKey: String
    }

    private static let signedURLMarker = "/storage/v1/object/sign/\(bucket)/"
    private static let versionQueryKey = "v"
    private static let resolveTTL: TimeInterval = 24 * 3600
    private static let resolveReuseMargin: TimeInterval = 4 * 3600
    // Serial queue instead of NSLock — lock()/unlock() is unavailable in async contexts (Swift 6).
    private static let resolveQueue = DispatchQueue(label: "com.appseed.storage.resolve")
    private static var resolveCache: [String: (url: URL, expiresAt: Date)] = [:]

    private static func cachedResolvedURL(for filePath: String) -> URL? {
        resolveQueue.sync {
            guard let cached = resolveCache[filePath],
                  cached.expiresAt > Date().addingTimeInterval(resolveReuseMargin) else { return nil }
            return cached.url
        }
    }

    private static func storeResolvedURL(_ url: URL, for filePath: String) {
        resolveQueue.sync {
            resolveCache[filePath] = (url, Date().addingTimeInterval(resolveTTL))
        }
    }

    static func resolveImageURL(_ stored: String, completion: @escaping AnyClosure<ResolvedImage?>) {
        guard let storedURL = URL(string: stored) else {
            completion(nil)
            return
        }
        guard let filePath = signedStoragePath(from: stored) else {
            // Not one of our signed storage URLs — use as-is.
            completion(ResolvedImage(url: storedURL, cacheKey: stored))
            return
        }

        let version = contentVersion(from: stored)
        let cacheKey = version.map { "\(filePath)#\($0)" } ?? filePath

        if let cached = cachedResolvedURL(for: filePath) {
            completion(ResolvedImage(url: restamped(cached, version), cacheKey: cacheKey))
            return
        }

        Task {
            do {
                let fresh = try await SupabaseManager.shared.client.storage
                    .from(bucket)
                    .createSignedURL(path: filePath, expiresIn: Int(resolveTTL))
                storeResolvedURL(fresh, for: filePath)
                log(.info, .supabase, "Re-signed storage URL: \(filePath)")
                await MainActor.run { completion(ResolvedImage(url: restamped(fresh, version), cacheKey: cacheKey)) }
            } catch {
                log(.error, .supabase, "Re-sign failed for \(filePath), using stored URL: \(error.localizedDescription)")
                await MainActor.run { completion(ResolvedImage(url: storedURL, cacheKey: cacheKey)) }
            }
        }
    }

    // "…/storage/v1/object/sign/avatars/<path>?token=…" → "<path>"
    private static func signedStoragePath(from stored: String) -> String? {
        guard let markerRange = stored.range(of: signedURLMarker) else { return nil }
        let tail = stored[markerRange.upperBound...]
        guard let path = tail.split(separator: "?", maxSplits: 1).first, !path.isEmpty else { return nil }
        return String(path).removingPercentEncoding ?? String(path)
    }

    // MARK: - Content Version
    // Stamp both the cache key and the request URL — memoised signed URLs repeat, so a key-only stamp still gets the old body.
    private static func stamping(_ absolute: String, with version: String) -> String {
        "\(absolute)\(absolute.contains("?") ? "&" : "?")\(versionQueryKey)=\(version)"
    }

    private static func newlyStamped(_ signedURL: URL) -> String {
        stamping(signedURL.absoluteString, with: String(Int(Date().timeIntervalSince1970 * 1000)))
    }

    private static func restamped(_ url: URL, _ version: String?) -> URL {
        guard let version, let stamped = URL(string: stamping(url.absoluteString, with: version)) else { return url }
        return stamped
    }

    private static func seedImageCache(data: Data, filePath: String, stamped: String) {
        guard let image = UIImage(data: data), let version = contentVersion(from: stamped) else { return }
        KingfisherManager.shared.cache.store(image, original: data, forKey: "\(filePath)#\(version)")
    }

    // Rows predating the stamp stay on the bare path until their next save.
    private static func contentVersion(from stored: String) -> String? {
        guard let version = URLComponents(string: stored)?
            .queryItems?
            .first(where: { $0.name == versionQueryKey })?
            .value, !version.isEmpty else { return nil }
        return version
    }

    // MARK: - Resize
    // Force scale 1.0 — UIScreen.main.scale (3× on iPhone) 9× the bitmap and overshoots Supabase bucket limits.
    private static func resized(_ image: UIImage, maxDimension: CGFloat, opaque: Bool) -> UIImage {
        guard maxDimension > 0 else { return image }
        let size = image.size
        let maxSide = max(size.width, size.height)

        let newSize: CGSize
        if maxSide > maxDimension {
            let ratio = maxDimension / maxSide
            newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        } else {
            newSize = size
        }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = opaque
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    // MARK: - Upload
    static func uploadImage(
        _ image: UIImage,
        path: StoragePath,
        fileName: String,
        compression: CGFloat = 0.7,
        completion: @escaping AnyClosure<String?>
    ) {
        let format = path.imageFormat(for: image)

        // Resize + encode off the main thread — 4K+ source blocks for 1-2s otherwise.
        Task.detached(priority: .userInitiated) {
            let resizedImage = resized(image, maxDimension: path.maxSize, opaque: format.opaque)
            guard let data = format.encode(resizedImage, compression: compression) else {
                await MainActor.run { completion(nil) }
                return
            }

            guard data.count <= maxUploadBytes else {
                log(.error, .supabase, "Upload skipped — \(data.count) bytes exceeds cap \(maxUploadBytes) for \(path.rawValue)")
                await MainActor.run { completion(nil) }
                return
            }

            let filePath = "\(path.rawValue)/\(fileName).\(format.fileExtension)"
            let stamped = await performUpload(data: data, filePath: filePath, contentType: format.contentType)
            await MainActor.run {
                if let stamped { seedImageCache(data: data, filePath: filePath, stamped: stamped) }
                completion(stamped)
            }
        }
    }

    // MARK: - Upload Raw Data
    static func uploadData(
        _ data: Data,
        path: StoragePath,
        fileName: String,
        contentType: String,
        completion: @escaping AnyClosure<String?>
    ) {
        let filePath = "\(path.rawValue)/\(fileName)"

        Task {
            let stamped = await performUpload(data: data, filePath: filePath, contentType: contentType)
            await MainActor.run {
                if let stamped { seedImageCache(data: data, filePath: filePath, stamped: stamped) }
                completion(stamped)
            }
        }
    }

    // MARK: - Private — Upload
    // Both upload entry points land here so the retry exists once. Returns the stamped signed URL,
    // or nil once the retries are spent. The caller seeds the cache and calls back in one main-thread
    // hop, so nothing can read the row between the two.
    private static func performUpload(
        data: Data,
        filePath: String,
        contentType: String,
        attempt: Int = 0
    ) async -> String? {
        do {
            try await SupabaseManager.shared.client.storage
                .from(bucket)
                .upload(
                    filePath,
                    data: data,
                    options: FileOptions(contentType: contentType, upsert: true)
                )

            let signedURL = try await SupabaseManager.shared.client.storage
                .from(bucket)
                .createSignedURL(path: filePath, expiresIn: 60 * 60 * 24 * 365)

            return newlyStamped(signedURL)
        } catch {
            // -1005 and friends are the connection dropping mid-body, not a rejection. The biggest
            // upload in a chain draws them most often, so without a retry a save fails on a
            // perfectly working network.
            if isTransient(error), attempt < maxUploadRetries {
                log(.warning, .supabase, "Storage upload retry \(attempt + 1): \(filePath) — \(error.localizedDescription)")
                try? await Task.sleep(nanoseconds: retryDelayNanoseconds)
                return await performUpload(data: data, filePath: filePath, contentType: contentType, attempt: attempt + 1)
            }
            log(.error, .supabase, "Storage upload failed: \(filePath) — \(error)")
            return nil
        }
    }

    // MARK: - Delete
    static func deleteImage(
        path: StoragePath,
        fileName: String,
        completion: AnyClosure<Error?>? = nil
    ) {
        // Format is per image, so the caller cannot know which extension was written.
        let filePaths = ImageFormat.allCases.map { "\(path.rawValue)/\(fileName).\($0.fileExtension)" }

        Task {
            do {
                try await SupabaseManager.shared.client.storage
                    .from(bucket)
                    .remove(paths: filePaths)

                await MainActor.run {
                    completion?(nil)
                }
            } catch {
                log(.error, .supabase, "Storage delete failed: \(error.localizedDescription)")
                await MainActor.run {
                    completion?(error)
                }
            }
        }
    }

    // MARK: - URL Parser
    // Returns the extension-less file name from the signed URL's final segment.
    static func extractFileName(fromURL urlString: String) -> String? {
        guard let path = URLComponents(string: urlString)?.path else { return nil }
        let last = (path as NSString).lastPathComponent
        let stem = (last as NSString).deletingPathExtension
        return stem.isEmpty ? nil : stem
    }

    // MARK: - Batch Delete (fire-and-forget)
    static func deleteImages(urls: [String], path: StoragePath) {
        for url in urls {
            guard let fileName = extractFileName(fromURL: url) else { continue }
            deleteImage(path: path, fileName: fileName)
        }
    }

    // MARK: - Path Delete
    // deleteImage appends the path's own extension, which suits the one-file-per-owner uploads but
    // not files that carry their own name. These take the bucket-relative path verbatim.
    static func deleteFiles(relativePaths: [String], completion: AnyClosure<Error?>? = nil) {
        guard !relativePaths.isEmpty else {
            completion?(nil)
            return
        }
        Task {
            do {
                try await SupabaseManager.shared.client.storage.from(bucket).remove(paths: relativePaths)
                await MainActor.run { completion?(nil) }
            } catch {
                log(.error, .supabase, "Storage path delete failed: \(error.localizedDescription)")
                await MainActor.run { completion?(error) }
            }
        }
    }

    // Signed URLs look like /storage/v1/object/sign/<bucket>/<relative/path>?token=…
    static func relativePath(fromSignedURL urlString: String) -> String? {
        guard let path = URLComponents(string: urlString)?.path else { return nil }
        let marker = "/\(bucket)/"
        guard let range = path.range(of: marker) else { return nil }
        let relative = String(path[range.upperBound...])
        return relative.isEmpty ? nil : relative
    }
}
