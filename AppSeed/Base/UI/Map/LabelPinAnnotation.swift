//
//  LabelPinAnnotation.swift
//  AppSeed
//
//  Created by Claude on 28.07.2026.
//

import MapKit

final class LabelPinAnnotation: MKPointAnnotation {

    // MARK: - Properties
    let id: String
    let text: String

    // MARK: - Init
    init(id: String, text: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.text = text
        super.init()
        self.coordinate = coordinate
    }
}
