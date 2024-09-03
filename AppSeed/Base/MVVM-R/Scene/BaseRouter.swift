//
//  BaseRouter.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

class BaseRouter: Router<BaseViewController<V>, V: BaseViewModel> {
    typealias V = U
    weak var viewController: V?
}
