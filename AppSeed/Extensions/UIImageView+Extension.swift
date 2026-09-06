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

    private enum AssociatedKeys {
        static var pendingImageSource: UInt8 = 0
    }

    // Guards the async resolve hop against cell reuse — a late resolve for a recycled
    // view must not overwrite the newer request's image.
    private var pendingImageSource: String? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.pendingImageSource) as? String }
        set { objc_setAssociatedObject(self, &AssociatedKeys.pendingImageSource, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: - Set
    // Re-signed at read time so stored 365-day tokens never expire on screen; the cache key tracks
    // the content version instead of the token, so rotation keeps the cache warm.
    func setImage(with string: String?, placeholder: UIImage? = nil) {
        guard let string else { return }
        pendingImageSource = string
        SupabaseStorageHelper.resolveImageURL(string) { [weak self] resolved in
            guard let self, self.pendingImageSource == string, let resolved else { return }
            self.kf.setImage(
                with: KF.ImageResource(downloadURL: resolved.url, cacheKey: resolved.cacheKey),
                placeholder: placeholder,
                options: Self.defaultOptions
            )
        }
    }

    func setImage(with url: URL?, placeholder: UIImage? = nil) {
        setImage(with: url?.absoluteString, placeholder: placeholder)
    }

    // Thumbnail-size targets (list cards): decode at target point size instead of
    // the full-size original; the original still lands in the disk cache for detail views.
    func setImage(with string: String?, downsampledTo size: CGSize, placeholder: UIImage? = nil) {
        guard let string else { return }
        pendingImageSource = string
        SupabaseStorageHelper.resolveImageURL(string) { [weak self] resolved in
            guard let self, self.pendingImageSource == string, let resolved else { return }
            let options: KingfisherOptionsInfo = [
                .processor(DownsamplingImageProcessor(size: size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(.fade(0.25))
            ]
            self.kf.setImage(
                with: KF.ImageResource(downloadURL: resolved.url, cacheKey: resolved.cacheKey),
                placeholder: placeholder,
                options: options
            )
        }
    }

    // MARK: - Download lifecycle
    func cancelImageDownload() {
        kf.cancelDownloadTask()
    }

    // MARK: - Retrieve
    static func retrieveImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        SupabaseStorageHelper.resolveImageURL(url.absoluteString) { resolved in
            guard let resolved else {
                completion(nil)
                return
            }
            KingfisherManager.shared.retrieveImage(
                with: KF.ImageResource(downloadURL: resolved.url, cacheKey: resolved.cacheKey)
            ) { result in
                switch result {
                case .success(let value): completion(value.image)
                case .failure: completion(nil)
                }
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
}
