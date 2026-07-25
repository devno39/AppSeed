//
//  ColorAction.swift
//  AppSeed
//
//  Created by tunay alver on 1.03.2026.
//

import UIKit

enum ColorAction: Colorable {
    case destructive

    var hex: Int {
        switch self {
        case .destructive:
            return 0xFF453A
        }
    }
}
