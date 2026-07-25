//
//  CGFloat+Extension.swift
//  AppSeed
//
//  Created by Claude on 19.01.2025.
//

import Foundation 
import UIKit

extension CGFloat {

    func clamped(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.min(Swift.max(self, min), max)
    }

    func lerp(to: CGFloat, progress: CGFloat) -> CGFloat {
        return self + (to - self) * progress
    }
}

extension Double {

    func clamped(min: Double, max: Double) -> Double {
        return Swift.min(Swift.max(self, min), max)
    }
}

extension Float {

    func clamped(min: Float, max: Float) -> Float {
        return Swift.min(Swift.max(self, min), max)
    }
}
