//
// UIImageView+Extension.swift
// AppSeed
//
// Created by Osman Emre Ömürlü on 31.01.2024.
//

import UIKit
import Kingfisher

extension UIImageView {
    // MARK: - Properties
    static let imageCache = ImageCache.default

    private static let defaultOptions: KingfisherOptionsInfo = [
        .scaleFactor(UIScreen.main.scale),
        .cacheOriginalImage,
        .processor(DefaultImageProcessor.default),
        .transition(.fade(0.25))
    ]

    // MARK: - Set
    func setImage(with url: URL?, placeholder: UIImage? = nil) {
        guard let url else { return }
        kf.setImage(with: url, placeholder: placeholder, options: Self.defaultOptions)
    }

    func setImage(with string: String?, placeholder: UIImage? = nil) {
        setImage(with: string.flatMap { URL(string: $0) }, placeholder: placeholder)
    }

    // MARK: - Download lifecycle
    func cancelImageDownload() {
        kf.cancelDownloadTask()
    }

    // MARK: - Retrieve
    // Plain Kingfisher fetch — the Supabase-signed-URL resolving variant lands with the Phase 2 core.
    static func retrieveImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value): completion(value.image)
            case .failure: completion(nil)
            }
        }
    }

    // MARK: - Cache configuration
    static func limitMemoryCacheSize(_ MB: Int) {
        imageCache.memoryStorage.config.totalCostLimit = MB * 1024 * 1024
    }

    static func limitMemoryCacheCount(_ count: Int) {
        imageCache.memoryStorage.config.totalCostLimit = count
    }

    static func setMaxCachePeriodInSeconds(_ seconds: Int) {
        imageCache.memoryStorage.config.expiration = .seconds(TimeInterval(seconds))
    }

    static func clearMemoryCache() {
        imageCache.clearMemoryCache()
    }

    static func clearDiskCache() {
        imageCache.clearDiskCache()
    }

    static func cleanExpiredDiskCache() {
        imageCache.cleanExpiredDiskCache()
    }

    // Supabase storage variants land with the Phase 2 core
}
