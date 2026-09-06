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
    case chevron_left
    case chevron_right
    case chevron_down
    case chevron_up_chevron_down
    case ellipsis
    case house
    case person_crop_circle

    // MARK: - Actions
    case plus
    case minus
    case checkmark
    case checkmark_circle_fill
    case circle
    case camera
    case photo_on_rectangle
    case arrow_triangle_2_circlepath_camera
    case xmark

    // MARK: - Feedback
    case heart_fill
    case bubble_left_fill
    case star_fill

    // MARK: - Misc
    case calendar
    case crown
    case info_circle
    case lock_fill
    case pin_fill

    // Case names map mechanically to SF Symbol names (_ → .).
    var symbolName: String {
        rawValue.replacingOccurrences(of: "_", with: ".")
    }
}
