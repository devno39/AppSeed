//
// UIImageView+Extension.swift
// AppSeed
//
// Created by Osman Emre Ömürlü on 31.01.2024.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImage(with url: URL, placeholder: UIImage? = nil, options: KingfisherOptionsInfo? = nil, completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        
        let cacheOptions: KingfisherOptionsInfo = [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(1)),
            .cacheOriginalImage,
            .processor(DefaultImageProcessor.default),
            .cacheSerializer(FormatIndicatedCacheSerializer.png)
        ]
        
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: options ?? cacheOptions,
            completionHandler: completionHandler
        )
    }
    
    // Advanced cache control
    static let imageCache = ImageCache.default
    
    // Limit the memory cache size to desired MB.
    static func limitMemoryCacheSize(_ MB: Int) {
        UIImageView.imageCache.memoryStorage.config.totalCostLimit = MB * 1024 * 1024
    }
    
    // Limit the memory cache to hold the maximum number of requested images.
    static func limitMemoryCacheCount(_ count: Int) {
        UIImageView.imageCache.memoryStorage.config.totalCostLimit = count
    }
    
    static func setMaxCachePeriodInSeconds(_ seconds: Int) {
        UIImageView.imageCache.memoryStorage.config.expiration = .seconds(TimeInterval(seconds))
    }
    
    static func clearMemoryCache() {
        UIImageView.imageCache.clearMemoryCache()
    }
    
    static func clearDiskCache() {
        UIImageView.imageCache.clearDiskCache()
    }
    
    static func cleanExpiredDiskCache() {
        UIImageView.imageCache.cleanExpiredDiskCache()
    }
}

