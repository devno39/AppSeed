//
//  PhotoStackAnnotation.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import MapKit

final class PhotoStackAnnotation: MKPointAnnotation {

    // MARK: - Properties
    let id: String
    let imageURLs: [String]
    let isBadged: Bool

    var imageCount: Int { imageURLs.count }

    // MARK: - Init
    init(id: String, imageURLs: [String], isBadged: Bool = false, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.imageURLs = imageURLs
        self.isBadged = isBadged
        super.init()
        self.coordinate = coordinate
    }
}
