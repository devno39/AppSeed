//
//  TimeInterval+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 25.02.2026.
//

import Foundation

extension TimeInterval {
    var toDateFromMilliseconds: Date {
        return Date(timeIntervalSince1970: self / 1000)
    }
}
