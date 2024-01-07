//
//  Palette.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

enum Palette: Colorable {
    case palette1
    case palette2
    
    var hex: Int {
        switch self {
        case .palette1:
            return 0xFFFFFF
        case .palette2:
            return 0x000000
        }
    }
}
