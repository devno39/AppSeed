//
//  String+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import Foundation

extension String {
    func toPriceDouble() -> Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        if let number = formatter.number(from: self) {
            return number.doubleValue
        } else {
            if self.contains("$") {
                formatter.locale = Locale(identifier: "en_US")
            } else if self.contains("€") {
                formatter.locale = Locale(identifier: "de_DE")
            } else if self.contains("₺") {
                formatter.locale = Locale(identifier: "tr_TR")
            }
            
            if let number = formatter.number(from: self) {
                return number.doubleValue
            }
            return nil
        }
    }

    func getLocale() -> Locale {
        if self.contains("$") {
            return Locale(identifier: "en_US")
        } else if self.contains("€") {
            return Locale(identifier: "de_DE")
        } else if self.contains("₺") {
            return Locale(identifier: "tr_TR")
        }

        return Locale.current
    }
}
