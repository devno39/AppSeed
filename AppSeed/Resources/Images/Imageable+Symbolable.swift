//
//  Imageable+Symbolable.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

protocol Imageable {
    var image: UIImage { get }
}

extension Imageable {
    var image: UIImage {
        UIImage(named: String(describing: self)) ?? UIImage()
    }
}

// MARK: - Symbol Size Presets
enum SymbolSize {
    case xxxSmall  // 12pt
    case xxSmall   // 14pt
    case xSmall    // 16pt
    case small     // 18pt
    case medium    // 20pt
    case large     // 24pt
    case xLarge    // 28pt
    case xxLarge   // 32pt
    case xxxLarge  // 36pt
    case custom(CGFloat)

    var pointSize: CGFloat {
        switch self {
        case .xxxSmall: return 12
        case .xxSmall: return 14
        case .xSmall: return 16
        case .small: return 18
        case .medium: return 20
        case .large: return 24
        case .xLarge: return 28
        case .xxLarge: return 32
        case .xxxLarge: return 36
        case .custom(let size): return size
        }
    }
}

// MARK: - Symbolable Protocol
protocol Symbolable {
    var symbolName: String { get }

    func symbol(size: CGFloat, weight: UIImage.SymbolWeight, scale: UIImage.SymbolScale) -> UIImage
    func symbol(size: SymbolSize, weight: UIImage.SymbolWeight) -> UIImage
    func symbol(tintColor: UIColor, size: SymbolSize, weight: UIImage.SymbolWeight) -> UIImage
    func symbolSmall() -> UIImage
    func symbolMedium() -> UIImage
    func symbolLarge() -> UIImage
}

extension Symbolable {
    func symbol(size: CGFloat = 15, weight: UIImage.SymbolWeight = .medium, scale: UIImage.SymbolScale = .default) -> UIImage {
        let configuration = UIImage.SymbolConfiguration(pointSize: size, weight: weight, scale: scale)
        let image = UIImage(systemName: symbolName, withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate) ?? UIImage()
        return image
    }

    func symbol(size: SymbolSize, weight: UIImage.SymbolWeight = .medium) -> UIImage {
        return symbol(size: size.pointSize, weight: weight, scale: .default)
    }

    func symbol(tintColor: UIColor, size: SymbolSize = .medium, weight: UIImage.SymbolWeight = .medium) -> UIImage {
        let configuration = UIImage.SymbolConfiguration(pointSize: size.pointSize, weight: weight)
        let image = UIImage(systemName: symbolName, withConfiguration: configuration)?
            .withTintColor(tintColor, renderingMode: .alwaysOriginal) ?? UIImage()
        return image
    }

    // MARK: - Quick Access Presets
    func symbolSmall() -> UIImage {
        return symbol(size: .small, weight: .medium)
    }

    func symbolMedium() -> UIImage {
        return symbol(size: .medium, weight: .medium)
    }

    func symbolLarge() -> UIImage {
        return symbol(size: .large, weight: .medium)
    }
}
