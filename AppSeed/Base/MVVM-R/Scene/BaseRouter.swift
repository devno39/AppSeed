//
//  BaseRouter.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

protocol BaseRouterProtocol: AnyObject {
    var viewController: UIViewController? { get set }
}

class BaseRouter: BaseRouterProtocol {
    weak var viewController: UIViewController?

    init() { }
}
