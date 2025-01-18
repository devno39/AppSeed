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

    // MARK: - Functions
    func setImage(with string: String?, placeholder: UIImage? = nil) {
        guard let string, let url = URL(string: string) else { return }
        
        let cacheOptions: KingfisherOptionsInfo = [
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
            .processor(DefaultImageProcessor.default)
        ]
        
        kf.setImage(with: url, placeholder: placeholder)
    }
    
    // MARK: - Static functions
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
