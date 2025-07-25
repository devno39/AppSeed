//
//  IAPHelper.swift
//  AppSeed
//
//  Created by tunay alver on 12.07.2025.
//

import RevenueCat
import Foundation

final class IAPHelper: NSObject {
    static let shared = IAPHelper()
    private let apiKey = "appl_MhxUuSSbDXPMljKBXoXKrqXBRPC"
    private(set) var userPlan: UserPlan = .free
    
    private enum Entitlements {
        static let premium = "premium"
    }

    private override init() {}

    func configure() {
        Purchases.shared.delegate = self
        Purchases.logLevel = .debug
        Purchases.configure(with: .init(withAPIKey: apiKey))
    }
    
    func getOfferings(completion: @escaping AnyClosure<Offerings?>) {
        Purchases.shared.getOfferings() { offerings, error in
            if let error = error {
                log(.error, .iap, "Failed to fetch offerings: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(offerings)
            }
        }
    }
    
    func getOffering(identifier: String, completion: @escaping AnyClosure<Offering?>) {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                log(.error, .iap, "Failed to fetch offerings: \(error.localizedDescription)")
                completion(nil)
            } else {
                let offering = offerings?.offering(identifier: identifier)
                completion(offering)
            }
        }
    }
    
    func purchase(package: Package, completion: @escaping BoolClosure) {
        Purchases.shared.purchase(package: package) { transaction, customerInfo, error, userCancelled in
            if let error = error {
                log(.error, .iap, "Purchase error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if userCancelled {
                log(.info, .iap, "Purchase cancelled by user")
                completion(false)
                return
            }
            
            if customerInfo?.entitlements[Entitlements.premium]?.isActive == true {
                log(.success, .iap, "Purchase success and premium is active")
                completion(true)
            } else {
                log(.warning, .iap, "Purchase success but premium not active")
                completion(false)
            }
        }
    }
    
    func restorePurchases(completion: @escaping BoolClosure) {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                log(.error, .iap, "Restore error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            log(.success, .iap, "Restore purchases: \(String(describing: customerInfo))")
            completion(true)
        }
    }
    
    func isPremium(completion: @escaping BoolClosure) {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let error = error {
                log(.error, .iap, "Fetching customer info: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let info = customerInfo else {
                completion(false)
                return
            }
            
            log(.info, .iap, "Entitlements: \(info.entitlements)")
            self.setUserPlan(from: info)
            
            let isActive = info.entitlements[Entitlements.premium]?.isActive == true
            completion(isActive)
        }
    }
    
    func setUserPlan(from info: CustomerInfo) {
        let entitlement = info.entitlements[Entitlements.premium]
        
        guard entitlement?.isActive == true else {
            self.userPlan = .free
            log(.info, .iap, "isActive fallback to free")
            return
        }
        
        for plan in UserPlan.allCases where plan.offeringId == entitlement?.productIdentifier {
            self.userPlan = plan
            log(.info, .iap, "matched: \(plan)")
            return
        }
        
        self.userPlan = .free
        log(.info, .iap, "fallback to free (product mismatch)")
    }
}

// MARK: - Delegate
extension IAPHelper: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        setUserPlan(from: customerInfo)
        log(.info, .iap, "Customer info updated via delegate")
    }
}
