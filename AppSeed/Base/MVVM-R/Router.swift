//
//  Router.swift
//  AppSeed
//
//  Created by tunay alver on 9.08.2023.
//

import UIKit

protocol RouterProtocol: AnyObject {
    associatedtype V: UIViewController
    var viewController: V? { get }
}

class Router<U: UIViewController>: RouterProtocol {
    typealias V = U
    weak var viewController: V?
}
