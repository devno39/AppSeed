//
//  ColorBackground.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

enum ColorBackground: Colorable {
    case backgroundPrimary
    
    var hex: Int {
        switch self {
        case .backgroundPrimary:
            return 0xFFFFFF
        }
    }
}
