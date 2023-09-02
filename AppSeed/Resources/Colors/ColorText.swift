//
//  ColorText.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

extension UIColor {
    static var textPrimary: UIColor {
        if let color = UIColor(named: "textPrimary") {
            return color
        }
        return UIColor(rgb: 0xFFFFFF)
    }
}
