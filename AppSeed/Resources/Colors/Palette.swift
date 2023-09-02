//
//  Palette.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

extension UIColor {
    static var palette1: UIColor {
        if let color = UIColor(named: "palette1") {
            return color
        }
        return UIColor(rgb: 0xFFFFFF)
    }
    static var palette2: UIColor {
        if let color = UIColor(named: "palette2") {
            return color
        }
        return UIColor(rgb: 0xFFFFFF)
    }
}
