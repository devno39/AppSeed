//
//  SupabaseStorageHelper.swift
//  AppSeed
//
//  Created by Claude on 31.03.2026.
//

import UIKit
import Supabase

struct SupabaseStorageHelper {

    // MARK: - Bucket
    private static let bucket = "avatars"

    // MARK: - Upload Caps
    // Resize output is typically ~150KB (memory) / ~400KB (profile PNG); 5MB cap guards against corrupt or oversized originals.
    private static let maxUploadBytes: Int = 5 * 1024 * 1024

    // MARK: - Image Format
    enum ImageFormat {
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

        // Profile images may have alpha (avatar PNGs) — JPEG flattens to white.
        var imageFormat: ImageFormat {
            switch self {
            case .profileImages: .png
            }
        }
    }

    // MARK: - Signed URL Resolution
    // Stored URLs carry a 365-day token with no refresh path — reads re-sign the embedded
    // storage path with a fresh 24h token so shown content never expires. Every failure
    // falls back to the stored URL: behavior is never worse than before this layer existed.
    struct ResolvedImage {
        let url: URL
        // Stable Kingfisher cache key — token rotation must not bust the image cache.
        let cacheKey: String
    }

    private static let signedURLMarker = "/storage/v1/object/sign/\(bucket)/"
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

        if let cached = cachedResolvedURL(for: filePath) {
            completion(ResolvedImage(url: cached, cacheKey: filePath))
            return
        }

        Task {
            do {
                let fresh = try await SupabaseManager.shared.client.storage
                    .from(bucket)
                    .createSignedURL(path: filePath, expiresIn: Int(resolveTTL))
                storeResolvedURL(fresh, for: filePath)
                log(.info, .supabase, "Re-signed storage URL: \(filePath)")
                await MainActor.run { completion(ResolvedImage(url: fresh, cacheKey: filePath)) }
            } catch {
                log(.error, .supabase, "Re-sign failed for \(filePath), using stored URL: \(error.localizedDescription)")
                await MainActor.run { completion(ResolvedImage(url: storedURL, cacheKey: filePath)) }
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
        let format = path.imageFormat

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

            do {
                try await SupabaseManager.shared.client.storage
                    .from(bucket)
                    .upload(
                        filePath,
                        data: data,
                        options: FileOptions(contentType: format.contentType, upsert: true)
                    )

                let signedURL = try await SupabaseManager.shared.client.storage
                    .from(bucket)
                    .createSignedURL(path: filePath, expiresIn: 60 * 60 * 24 * 365)

                await MainActor.run {
                    completion(signedURL.absoluteString)
                }
            } catch {
                log(.error, .supabase, "Storage upload failed: \(error.localizedDescription)")
                await MainActor.run {
                    completion(nil)
                }
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

                await MainActor.run {
                    completion(signedURL.absoluteString)
                }
            } catch {
                log(.error, .supabase, "Storage data upload failed: \(error.localizedDescription)")
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Delete
    static func deleteImage(
        path: StoragePath,
        fileName: String,
        completion: AnyClosure<Error?>? = nil
    ) {
        let filePath = "\(path.rawValue)/\(fileName).\(path.imageFormat.fileExtension)"

        Task {
            do {
                try await SupabaseManager.shared.client.storage
                    .from(bucket)
                    .remove(paths: [filePath])

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
}
