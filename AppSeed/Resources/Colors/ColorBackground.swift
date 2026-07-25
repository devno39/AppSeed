//
//  ColorBackground.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

enum ColorBackground: Colorable {
    case backgroundPrimary
    case backgroundSecondary
    case backgroundTertiary
    case backgroundBorder
    case shadowPrimary

    var hex: Int {
        switch self {
        case .backgroundPrimary:
            return 0xF8F8F8
        case .backgroundSecondary:
            return 0xFFFFFF
        case .backgroundTertiary:
            return 0xF0F0F0
        case .backgroundBorder:
            return 0xEBEBEB
        case .shadowPrimary:
            return 0x000000
        }
    }
}
