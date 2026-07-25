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

    func dismissPresented(completion: (() -> Void)? = nil) {
        viewController?.presentedViewController?.dismiss(animated: true, completion: completion)
    }
}

// MARK: - Share Route
// System share sheet — no scene of its own, so the route lives with BaseRouter.
protocol ShareRoute {
    func presentShareSheet(items: [Any], sourceView: UIView?)
}

extension ShareRoute where Self: BaseRouter {
    func presentShareSheet(items: [Any], sourceView: UIView? = nil) {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = sourceView ?? viewController?.view
        viewController?.present(vc, animated: true)
    }
}
