//
//  Configuration.swift
//  AppSeed
//
//  Created by tunay alver on 2.09.2023.
//

import UIKit

final class Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    
    static var isRelease: Bool {
        #if Release
        return true
        #else
        return false
        #endif
    }

    static var isDevelop: Bool {
        #if Develop
        return true
        #else
        return false
        #endif
    }
    
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

extension Configuration {
    static var isIpad: Bool {
        UIDevice.isIpad
    }

    static var appVersion: String {
        UIApplication.appVersion
    }
}
