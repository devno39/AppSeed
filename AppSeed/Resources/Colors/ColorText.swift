//
//  ColorText.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

enum ColorText: Colorable {
    case textPrimary
    case textSecondary

    var hex: Int {
        switch self {
        case .textPrimary:
            return 0x1A1A1A
        case .textSecondary:
            return 0x808080
        }
    }
}
