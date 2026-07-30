//
//  UIImage+Extension.swift
//  AppSeed
//
//  Created by Claude on 13.03.2026.
//

import UIKit

extension UIImage {

    func withGradientFill(topColor: UIColor, bottomColor: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 1]
            ) else { return }
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: rect.midX, y: 0),
                end: CGPoint(x: rect.midX, y: rect.height),
                options: []
            )
            draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        }
    }

    func withPaletteGradient() -> UIImage {
        withGradientFill(topColor: Palette.palette2.color, bottomColor: Palette.palette1.color)
    }
}
