//
//  QRHelper.swift
//  AppSeed
//
//  Created by Claude on 24.03.2026.
//

import UIKit
import CoreImage.CIFilterBuiltins

final class QRHelper {
    static let shared = QRHelper()

    private init() {}

    // MARK: - Generate
    func generateQRCode(
        from string: String,
        size: CGFloat = 200,
        dotColor: UIColor = Palette.palette1.color,
        backgroundColor: UIColor = .clear,
        logo: UIImage? = nil
    ) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let ciImage = filter.outputImage else { return nil }

        // Colorize
        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = ciImage
        colorFilter.color0 = CIColor(color: dotColor)
        colorFilter.color1 = CIColor(color: backgroundColor)

        guard let coloredImage = colorFilter.outputImage else { return nil }

        let scale = size / coloredImage.extent.width
        let transformed = coloredImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = CIContext().createCGImage(transformed, from: transformed.extent) else { return nil }
        var qrImage = UIImage(cgImage: cgImage)

        // Embed logo
        if let logo {
            qrImage = embedLogo(logo, in: qrImage, qrSize: size)
        }

        return qrImage
    }

    // MARK: - Logo
    private func embedLogo(_ logo: UIImage, in qrImage: UIImage, qrSize: CGFloat) -> UIImage {
        let logoSize = qrSize * 0.22
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: qrSize, height: qrSize))

        return renderer.image { context in
            // Draw QR
            qrImage.draw(in: CGRect(origin: .zero, size: CGSize(width: qrSize, height: qrSize)))

            // Logo background circle (clear zone for scanability)
            let circleSize = logoSize + 12
            let circleOrigin = CGPoint(x: (qrSize - circleSize) / 2, y: (qrSize - circleSize) / 2)
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: circleOrigin, size: CGSize(width: circleSize, height: circleSize)))
            UIColor.white.setFill()
            circlePath.fill()

            // Draw logo
            let logoOrigin = CGPoint(x: (qrSize - logoSize) / 2, y: (qrSize - logoSize) / 2)
            logo.draw(in: CGRect(origin: logoOrigin, size: CGSize(width: logoSize, height: logoSize)))
        }
    }
}
