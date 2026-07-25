//
//  ___VARIABLE_name___Router.swift
//  AppSeed
//

import UIKit

// MARK: - Route Protocol
protocol ___VARIABLE_name___Route {
    func present___VARIABLE_name___()
}

extension ___VARIABLE_name___Route where Self: BaseRouter {
    func present___VARIABLE_name___() {
        let vc = ___VARIABLE_name___Builder().build()
        vc.modalPresentationStyle = .overFullScreen
        viewController?.present(vc, animated: false)
    }
}

// MARK: - Router
final class ___VARIABLE_name___Router: BaseRouter { }
