//
//  RemoteConfigKeys.swift
//  AppSeed
//
//  Created by tunay alver on 14.02.2026.
//

import Foundation

enum RemoteConfigKeys: String {
    // bool for expectedType can be removed
    case bool_default
    // review
    case review_version
    // gpt
    case gptKey
    case gpt_model_free
    case gpt_model_premium
    // replicate
    case replicateKey
    // falai
    case falaiKey
    // version
    case minimum_supported_version

    var expectedType: Any.Type {
        switch self {
        case .bool_default:
            return Bool.self
        case .gptKey, .replicateKey, .falaiKey, .gpt_model_free, .gpt_model_premium, .minimum_supported_version:
            return String.self
        default:
            return Int.self
        }
    }
}
