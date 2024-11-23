//
//  SFSymbols.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

enum Symbols: Symbolable {
    case apple_logo
    
    var symbolName: String {
        switch self {
        case .apple_logo:
            return "apple.logo"
        }
    }
}
