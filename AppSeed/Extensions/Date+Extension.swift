//
//  Date+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import Foundation

// TODO: - better
public extension Date {
    static func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    static func currentDateUTC() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
