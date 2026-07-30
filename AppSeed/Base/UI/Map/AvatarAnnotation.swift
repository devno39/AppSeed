//
//  AvatarAnnotation.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import MapKit

final class AvatarAnnotation: MKPointAnnotation {

    // MARK: - Properties
    let id: String
    let imageURL: String?
    let caption: String?
    let isHighlighted: Bool

    // MARK: - Init
    init(
        id: String,
        imageURL: String?,
        caption: String? = nil,
        isHighlighted: Bool = false,
        coordinate: CLLocationCoordinate2D
    ) {
        self.id = id
        self.imageURL = imageURL
        self.caption = caption
        self.isHighlighted = isHighlighted
        super.init()
        self.coordinate = coordinate
    }
}
