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

// MARK: - Trim
extension UIImage {

    // Crops fully transparent edges away. Useful whenever a glyph, sticker or exported drawing has
    // to sit tight inside its own frame: font metrics describe the line box, not the pixels, and
    // colour emoji carry no glyph path to measure at all.
    func trimmingTransparentPixels(alphaThreshold: UInt8 = 8) -> UIImage? {
        guard let cgImage,
              let bounds = cgImage.opaquePixelBounds(alphaThreshold: alphaThreshold),
              let cropped = cgImage.cropping(to: bounds) else { return nil }
        return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
    }
}

// MARK: - Opaque Bounds
extension CGImage {

    // Nil when every pixel is below the threshold — an empty image has no meaningful bounds.
    func opaquePixelBounds(alphaThreshold: UInt8 = 8) -> CGRect? {
        guard bitsPerPixel / 8 >= 4,
              let data = dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return nil }

        let pixelBytes = bitsPerPixel / 8
        var minX = width, minY = height, maxX = -1, maxY = -1

        for y in 0..<height {
            let row = y * bytesPerRow
            for x in 0..<width where bytes[row + x * pixelBytes + 3] > alphaThreshold {
                if x < minX { minX = x }
                if x > maxX { maxX = x }
                if y < minY { minY = y }
                if y > maxY { maxY = y }
            }
        }

        guard maxX >= minX, maxY >= minY else { return nil }
        return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    }
}

// MARK: - Sticker Outline
extension UIImage {

    // Follows the alpha silhouette rather than the frame — a rectangle around a cut-out shape reads
    // as a border, only the contour reads as a sticker. The keyline keeps the white edge visible on
    // white backgrounds without a drop shadow.
    func stickerOutlined(
        width: CGFloat,
        color: UIColor = .white,
        keyline: UIColor = UIColor.black.withAlphaComponent(0.14)
    ) -> UIImage? {
        guard width > 0, size.width > 0, size.height > 0 else { return self }

        let bounds = CGRect(origin: .zero, size: size)
        let silhouette = tinted(color, in: bounds)
        let edge = tinted(keyline, in: bounds)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = false

        let padded = CGSize(width: size.width + width * 2, height: size.height + width * 2)
        let origin = CGPoint(x: width, y: width)

        return UIGraphicsImageRenderer(size: padded, format: format).image { _ in
            ring(edge, around: origin, radius: width)
            ring(silhouette, around: origin, radius: max(width - 0.5, 0))
            draw(at: origin)
        }
    }

    // MARK: - Private
    // sourceIn keeps the destination alpha and replaces its colour, which turns any image — colour
    // emoji included — into a flat silhouette of itself.
    private func tinted(_ color: UIColor, in bounds: CGRect) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        format.opaque = false
        return UIGraphicsImageRenderer(size: bounds.size, format: format).image { context in
            draw(in: bounds)
            color.setFill()
            context.fill(bounds, blendMode: .sourceIn)
        }
    }

    private func ring(_ image: UIImage, around origin: CGPoint, radius: CGFloat) {
        guard radius > 0 else { return }
        for step in 0..<Self.outlineSteps {
            let angle = CGFloat(step) / CGFloat(Self.outlineSteps) * 2 * .pi
            image.draw(at: CGPoint(x: origin.x + cos(angle) * radius, y: origin.y + sin(angle) * radius))
        }
    }

    private static let outlineSteps = 24
}

// MARK: - Size Bounded Encoding
extension UIImage {

    // Encodes to JPEG small enough to actually upload. Buckets reject oversized objects, and a
    // rejected upload surfaces as "could not be saved" with nothing to act on — so the ceiling is
    // enforced here, before the request goes out.
    func jpegData(fitting maxBytes: Int, quality: CGFloat = 0.85, minimumQuality: CGFloat = 0.4) -> Data? {
        var quality = quality
        var data = jpegData(compressionQuality: quality)

        while let current = data, current.count > maxBytes, quality > minimumQuality {
            quality = max(quality - 0.1, minimumQuality)
            data = jpegData(compressionQuality: quality)
        }

        guard let current = data, current.count > maxBytes else { return data }

        // Quality alone was not enough — drop the pixels too. sqrt because bytes scale with area.
        let ratio = max(sqrt(CGFloat(maxBytes) / CGFloat(current.count)), 0.2)
        let target = CGSize(width: floor(size.width * ratio), height: floor(size.height * ratio))
        guard target.width >= 1, target.height >= 1 else { return data }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let shrunk = UIGraphicsImageRenderer(size: target, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: target))
        }
        return shrunk.jpegData(compressionQuality: quality) ?? data
    }
}

// MARK: - Alpha
extension UIImage {

    // The channel, not the pixels: an opaque PNG kept as PNG costs kilobytes, a transparent one
    // flattened to JPEG is unrecoverable.
    var carriesAlpha: Bool {
        guard let alphaInfo = cgImage?.alphaInfo else { return true }
        switch alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast:
            return true
        case .none, .noneSkipFirst, .noneSkipLast, .alphaOnly:
            return false
        @unknown default:
            return true
        }
    }
}
