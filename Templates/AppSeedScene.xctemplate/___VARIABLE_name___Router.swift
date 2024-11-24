//
//  RouterTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit

// MARK: - Route Protocol
protocol ___VARIABLE_name___Route {
    func push___VARIABLE_name___()
}

extension ___VARIABLE_name___Route where Self: BaseRouterProtocol {
    func push___VARIABLE_name___() {
        let vc = ___VARIABLE_name___Builder().build()
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Router
final class ___VARIABLE_name___Router: BaseRouter { }
