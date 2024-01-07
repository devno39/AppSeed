//
//  SFSymbols.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

enum Symbols: Symbolable {
    case magnifyingglass
    case xmark_circle
    case heart
    case heart_fill
    
    var symbolName: String {
        switch self {
        case .magnifyingglass:
            return "magnifyingglass"
        case .xmark_circle:
            return "xmark.circle"
        case .heart:
            return "heart"
        case .heart_fill:
            return "heart.fill"
        }
    }
}
