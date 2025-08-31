//
//  UserPlan.swift
//  AppSeed
//
//  Created by tunay alver on 12.07.2025.
//

import Foundation

enum UserPlan: CaseIterable {
    case free, monthly, yearly
    
    var offeringId: String {
        switch self {
        case .free:
            return ""
        case .monthly:
            return "subscription_monthly"
        case .yearly:
            return "subscription_yearly"
        }
    }
    
    var gptMaxTokens: Int {
        switch self {
        case .free: return 500
        case .monthly, .yearly: return 1000
        }
    }
}
