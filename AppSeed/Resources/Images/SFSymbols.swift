//
//  SFSymbols.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

enum Symbols: String, Symbolable {
    // MARK: - Brand
    case apple_logo

    // MARK: - Navigation
    case chevron_right
    case chevron_up_chevron_down

    // MARK: - Actions
    case plus
    case minus
    case checkmark
    case camera

    // MARK: - Misc
    case calendar
    case info_circle

    // Case names map mechanically to SF Symbol names (_ → .).
    var symbolName: String {
        rawValue.replacingOccurrences(of: "_", with: ".")
    }
}
