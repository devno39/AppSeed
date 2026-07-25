//
//  PaywallViewModel.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit
import RevenueCat

// MARK: - Source
protocol PaywallViewModelDataSource {
    var monthlyPrice: String { get }
    var yearlyPrice: String { get }
    var yearlyDiscountBadge: String? { get }
}

// MARK: - Function
protocol PaywallViewModelFunctionSource {
    func fetchOfferings()
    func purchase(plan: UserPlan, completion: @escaping BoolClosure)
    func restore(completion: @escaping BoolClosure)
    func openTerms()
    func openPrivacy()
}

// MARK: - Protocol
protocol PaywallViewModelProtocol: BaseViewModelProtocol,
                                   PaywallViewModelDataSource,
                                   PaywallViewModelFunctionSource {}

// MARK: - ViewModel
final class PaywallViewModel: BaseViewModel, PaywallViewModelProtocol {

    // MARK: - Closure
    var onPricesLoaded: EmptyClosure?

    // MARK: - Properties
    private var offerings: Offerings?
    private(set) var monthlyPrice: String = ""
    private(set) var yearlyPrice: String = ""
    private(set) var yearlyDiscountBadge: String?

    // MARK: - Init
    override init() {
        super.init()
        fetchOfferings()
    }

    // MARK: - Offerings
    func fetchOfferings() {
        IAPHelper.shared.getOfferings { [weak self] offerings in
            guard let self, let offerings else { return }
            self.offerings = offerings

            if let monthly = offerings.current?.monthly {
                self.monthlyPrice = monthly.localizedPriceString
            }
            if let annual = offerings.current?.annual {
                self.yearlyPrice = annual.localizedPriceString
            }

            self.yearlyDiscountBadge = self.calculateYearlyDiscountBadge(from: offerings)
            self.onPricesLoaded?()
        }
    }

    // MARK: - Discount
    private func calculateYearlyDiscountBadge(from offerings: Offerings) -> String? {
        guard let monthly = offerings.current?.monthly,
              let annual = offerings.current?.annual else { return nil }

        let monthlyAnnualEquivalent = monthly.storeProduct.price * 12
        guard monthlyAnnualEquivalent > 0 else { return nil }

        let ratio = (annual.storeProduct.price as NSDecimalNumber).doubleValue
            / (monthlyAnnualEquivalent as NSDecimalNumber).doubleValue
        let percent = Int(round((1 - ratio) * 100))
        guard percent > 0 else { return nil }

        return String(format: PaywallLocalizable.plan_save, percent)
    }

    // MARK: - Purchase
    func purchase(plan: UserPlan, completion: @escaping BoolClosure) {
        guard let package = package(for: plan) else {
            completion(false)
            return
        }
        IAPHelper.shared.purchase(package: package, completion: completion)
    }

    // MARK: - Restore
    func restore(completion: @escaping BoolClosure) {
        IAPHelper.shared.restorePurchases(completion: completion)
    }

    // MARK: - Links
    func openTerms() {
        guard let url = URL(string: Configuration.termsURL) else { return }
        UIApplication.shared.open(url)
    }

    func openPrivacy() {
        guard let url = URL(string: Configuration.privacyURL) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Private
    private func package(for plan: UserPlan) -> Package? {
        switch plan {
        case .monthly: return offerings?.current?.monthly
        case .yearly:  return offerings?.current?.annual
        case .free:    return nil
        }
    }
}
