//
//  EmojiRenderer.swift
//  AppSeed
//
//  Created by Claude on 21.08.2026.
//

import UIKit

// Turns an emoji into a picture, because that is what it is. Font metrics cannot size one — the
// line box they describe is not the glyph, and colour emoji carry no path to measure.
enum EmojiRenderer {

    // MARK: - Rendered
    struct Rendered {
        let image: UIImage
        let aspect: CGFloat

        // Normalised on the longest side so every emoji arrives with the same visual weight —
        // measuring each glyph's own height instead makes ❤️ land 7% shorter than 😀 at the same
        // requested size, which reads as an accident rather than a choice.
        func size(forLongestSide side: CGFloat) -> CGSize {
            aspect >= 1
                ? CGSize(width: ceil(side), height: ceil(side / aspect))
                : CGSize(width: ceil(side * aspect), height: ceil(side))
        }
    }

    // MARK: - Constants
    // Well above any on-screen size so scaling down stays crisp; one render serves every use.
    // Rasterised once and scaled to the element's size, so this is the ceiling on sharpness.
    private static let referenceSize: CGFloat = 240
    private static let outlineRatio: CGFloat = 0.045

    // MARK: - Properties
    private static var cache: [String: Rendered] = [:]

    // MARK: - Render
    static func render(_ emoji: String) -> Rendered? {
        guard !emoji.isEmpty else { return nil }
        if let cached = cache[emoji] { return cached }

        let string = NSAttributedString(string: emoji, attributes: [
            .font: UIFont.systemFont(ofSize: referenceSize)
        ])
        let box = string.boundingRect(
            with: CGSize(width: referenceSize * 6, height: referenceSize * 6),
            options: [.usesLineFragmentOrigin],
            context: nil
        )
        let size = CGSize(width: ceil(box.width), height: ceil(box.height))
        guard size.width >= 1, size.height >= 1 else { return nil }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 2
        format.opaque = false
        let rendered = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            string.draw(with: CGRect(origin: .zero, size: size), options: [.usesLineFragmentOrigin], context: nil)
        }

        guard let trimmed = rendered.trimmingTransparentPixels(), trimmed.size.height > 0 else { return nil }

        // Baked in rather than drawn at display time so the image still IS its own bounds — box,
        // size and selection frame downstream need no knowledge of the outline.
        let outlined = trimmed.stickerOutlined(width: max(trimmed.size.height * outlineRatio, 2)) ?? trimmed

        let result = Rendered(image: outlined, aspect: outlined.size.width / outlined.size.height)
        cache[emoji] = result
        return result
    }
}
