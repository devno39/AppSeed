//
//  ColorText.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

enum ColorText: Colorable {
    case textPrimary
    
    var hex: Int {
        switch self {
        case .textPrimary:
            return 0x000000
        }
    }
}
