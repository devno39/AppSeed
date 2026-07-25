//
//  Palette.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

enum Palette {
    case palette1
    case palette2
    case palette3

    var color: UIColor {
        PaletteManager.shared.color(for: self)
    }

    // MARK: - Gradient Colors
    static var sunsetGradient: [CGColor] {
        [
            Palette.palette1.color.cgColor,
            Palette.palette3.color.cgColor
        ]
    }

    static var softGlowGradient: [CGColor] {
        [
            Palette.palette1.color.withAlphaComponent(0.25).cgColor,
            Palette.palette3.color.withAlphaComponent(0.08).cgColor,
            UIColor.clear.cgColor
        ]
    }
}
