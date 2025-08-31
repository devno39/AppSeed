//
//  Double+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import Foundation

extension Double {
    func formatAsCurrency(locale: Locale) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: NSNumber(value: self))
    }
}
