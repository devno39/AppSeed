//
//  IAPHelper.swift
//  AppSeed
//
//  Created by tunay alver on 12.07.2025.
//

import RevenueCat
import Foundation
import WidgetKit

// MARK: - Notification
extension Notification.Name {
    static let premiumStatusDidChange = Notification.Name("premiumStatusDidChange")
    static let openPaywallRequested = Notification.Name("openPaywallRequested")
}

// MARK: - IAPHelper
final class IAPHelper: NSObject {
    static let shared = IAPHelper()
    private let apiKey = "REVENUECAT_API_KEY"
    private(set) var userPlan: UserPlan = .free

    private enum Entitlements {
        static let premium = "premium"
    }

    private override init() {}

    // MARK: - Configure
    func configure() {
        Purchases.logLevel = .debug
        Purchases.configure(with: .init(withAPIKey: apiKey))
        Purchases.shared.delegate = self

        // Widgets render before RevenueCat's first network answer — an unset mirror reads as free.
        if let cached = Purchases.shared.cachedCustomerInfo {
            setUserPlan(from: cached)
        } else {
            AppGroupStorage.isPro = false
        }
    }

    // MARK: - Identity
    // Without this RevenueCat stays on the device's anonymous id and purchases never follow the account.
    func logIn(userId: String) {
        Purchases.shared.logIn(userId) { [weak self] customerInfo, _, error in
            if let error {
                log(.error, .iap, "RC logIn failed: \(error.localizedDescription)")
                return
            }
            if let info = customerInfo {
                self?.setUserPlan(from: info)
            }
        }
    }

    func logOut() {
        Purchases.shared.logOut { _, error in
            if let error {
                log(.error, .iap, "RC logOut failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Premium State
    var isPremium: Bool {
        Purchases.shared.cachedCustomerInfo?.entitlements[Entitlements.premium]?.isActive == true
    }

    // `isPremium` reads false until RevenueCat's first response lands — a gate that treats that
    // window as "free" shows the paywall to a paying user on every cold launch.
    var entitlementsKnown: Bool {
        Purchases.shared.cachedCustomerInfo != nil
    }

    // Covers the cold window before RevenueCat replies: the last known state, mirrored to the
    // App Group so the widgets read it too.
    var premiumIncludingLastKnown: Bool {
        isPremium || AppGroupStorage.isPro
    }

    func refreshFromForeground() {
        Purchases.shared.invalidateCustomerInfoCache()
        Purchases.shared.getCustomerInfo { [weak self] info, error in
            if let error {
                log(.warning, .iap, "Foreground refresh failed: \(error.localizedDescription)")
                return
            }
            if let info { self?.setUserPlan(from: info) }
        }
    }

    func checkPremium(completion: @escaping BoolClosure) {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            if let error {
                log(.error, .iap, "Fetching customer info: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let info = customerInfo else {
                completion(false)
                return
            }

            self?.setUserPlan(from: info)
            completion(info.entitlements[Entitlements.premium]?.isActive == true)
        }
    }

    // MARK: - Offerings
    func getOfferings(completion: @escaping AnyClosure<Offerings?>) {
        Purchases.shared.getOfferings { offerings, error in
            if let error {
                log(.error, .iap, "Failed to fetch offerings: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(offerings)
            }
        }
    }

    func getOffering(identifier: String, completion: @escaping AnyClosure<Offering?>) {
        Purchases.shared.getOfferings { offerings, error in
            if let error {
                log(.error, .iap, "Failed to fetch offerings: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(offerings?.offering(identifier: identifier))
            }
        }
    }

    // MARK: - Purchase
    func purchase(package: Package, completion: @escaping BoolClosure) {
        Purchases.shared.purchase(package: package) { _, customerInfo, error, userCancelled in
            if let error {
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
                log(.success, .iap, "Purchase success — premium active")
                completion(true)
            } else {
                log(.warning, .iap, "Purchase success but premium not active")
                completion(false)
            }
        }
    }

    // MARK: - Restore
    func restorePurchases(completion: @escaping BoolClosure) {
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            if let error {
                log(.error, .iap, "Restore error: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let info = customerInfo {
                self?.setUserPlan(from: info)
            }
            completion(customerInfo?.entitlements[Entitlements.premium]?.isActive == true)
        }
    }

    // MARK: - Private
    private func setUserPlan(from info: CustomerInfo) {
        let entitlement = info.entitlements[Entitlements.premium]

        guard entitlement?.isActive == true else {
            updatePlan(.free)
            return
        }

        for plan in UserPlan.allCases where plan.offeringId == entitlement?.productIdentifier {
            updatePlan(plan)
            return
        }

        // Active but unknown product — a new SKU must not read as free.
        updatePlan(.monthly)
    }

    private func syncPremiumState() {
        // RevenueCat's cache is empty until its first response — a false downgrade strips the palette.
        let wasPro = AppGroupStorage.isPro
        let nowPro = isPremium

        guard entitlementsKnown || nowPro else { return }

        AppGroupStorage.isPro = nowPro
        if wasPro && !nowPro {
            PaletteManager.shared.resetToDefaultIfNeeded()
        }
        if !wasPro && nowPro {
            // Gated handlers skipped every write while free — a reload alone renders empty widgets.
            WidgetSyncService.shared.sync(kinds: Set(WidgetSyncKind.allCases), reason: .manual)
        }
    }

    private func updatePlan(_ plan: UserPlan) {
        let changed = userPlan != plan
        userPlan = plan

        syncPremiumState()

        if changed {
            log(.info, .iap, "Plan changed: \(plan)")
            NotificationCenter.default.post(name: .premiumStatusDidChange, object: nil)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

// MARK: - Delegate
extension IAPHelper: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        setUserPlan(from: customerInfo)
    }
}
