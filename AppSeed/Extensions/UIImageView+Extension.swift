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
    func setImage(with string: String, 
                  placeholder: UIImage? = nil,
                  options: KingfisherOptionsInfo? = nil,
                  completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) {
        guard let url = URL(string: string) else { return }
        
        let cacheOptions: KingfisherOptionsInfo = [.scaleFactor(UIScreen.main.scale),
                                                   .cacheOriginalImage,
                                                   .processor(DefaultImageProcessor.default)]
        
        self.kf.setImage(with: url,
                         placeholder: placeholder,
                         options: options ?? cacheOptions,
                         completionHandler: completionHandler)
    }
    
    // MARK: - Static functions
    static func limitMemoryCacheSize(_ MB: Int) {
        self.imageCache.memoryStorage.config.totalCostLimit = MB * 1024 * 1024
    }
    
    static func limitMemoryCacheCount(_ count: Int) {
        self.imageCache.memoryStorage.config.totalCostLimit = count
    }
    
    static func setMaxCachePeriodInSeconds(_ seconds: Int) {
        self.imageCache.memoryStorage.config.expiration = .seconds(TimeInterval(seconds))
    }
    
    static func clearMemoryCache() {
        self.imageCache.clearMemoryCache()
    }
    
    static func clearDiskCache() {
        self.imageCache.clearDiskCache()
    }
    
    static func cleanExpiredDiskCache() {
        self.imageCache.cleanExpiredDiskCache()
    }
}
