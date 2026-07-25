//
//  NonceGenerator.swift
//  AppSeed
//
//  Created by tunay alver on 14.02.2026.
//

import Foundation
import CryptoKit
import Security

enum NonceGenerator {

    static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }

    static func random(length: Int = 32) -> String {
        precondition(length > 0)

        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length

        while remaining > 0 {
            var randomBytes = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
            guard status == errSecSuccess else {
                fatalError("Unable to generate nonce. OSStatus: \(status)")
            }

            for byte in randomBytes {
                if remaining == 0 { break }
                result.append(charset[Int(byte) % charset.count])
                remaining -= 1
            }
        }
        return result
    }
}
