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

protocol Symbolable {
    var symbolName: String { get }
    func symbol(size: CGFloat, weight: UIImage.SymbolWeight) -> UIImage
}

extension Symbolable {
    func symbol(size: CGFloat = 15, weight: UIImage.SymbolWeight = .medium) -> UIImage {
        let configuration = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        
        return UIImage(systemName: symbolName, withConfiguration: configuration)?
            .withRenderingMode(.alwaysTemplate) ?? UIImage()
    }
}
