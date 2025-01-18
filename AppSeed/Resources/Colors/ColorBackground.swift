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

    case shadowPrimary
    
    var hex: Int {
        switch self {
        case .backgroundPrimary:
            return 0xFFFFFF
        case .backgroundSecondary:
            return 0x333333

        case .shadowPrimary:
            return 0x000000
        }
    }
}
