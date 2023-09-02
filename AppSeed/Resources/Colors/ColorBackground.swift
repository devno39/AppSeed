//
//  ColorBackground.swift
//  BaseKit
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

extension UIColor {
    static var backgroundPrimary: UIColor {
        if let color = UIColor(named: "backgroundPrimary") {
            return color
        }
        return UIColor(rgb: 0xFFFFFF)
    }
}
