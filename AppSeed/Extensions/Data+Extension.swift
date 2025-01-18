//
//  Data+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 11.01.2025.
//

import Foundation

extension Data {
    var prettyString: NSString? {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) ?? nil
    }
}
