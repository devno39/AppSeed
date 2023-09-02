//
//  Navigator.swift
//  AppSeed
//
//  Created by tunay alver on 9.08.2023.
//

import UIKit

protocol Navigatable {
    func create() -> UIViewController
    func createWithNavigation() -> UIViewController
}

class Navigator: Navigatable {
    func create() -> UIViewController {
        fatalError("override create()")
    }
    
    func createWithNavigation() -> UIViewController {
        fatalError("override createWithNavigation()")
    }
}

extension UIViewController {
    enum DisplayStyle {
        case push
        case present
        case presentWithNavigation
    }
    
    fileprivate func show(_ viewController: UIViewController, style: DisplayStyle, animated: Bool) {
        switch style {
        case .present:
            present(viewController, animated: animated, completion: nil)
        case .presentWithNavigation:
            let navigationController = BaseNavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .overFullScreen
            present(navigationController, animated: animated, completion: nil)
        case .push:
            guard let navigationController = navigationController else { return }
            navigationController.pushViewController(viewController, animated: animated)
        }
    }
    
    fileprivate func back(_ style: DisplayStyle, animated: Bool, completion: AnyCallback<()>? = nil) {
        switch style {
        case .present, .presentWithNavigation:
            dismiss(animated: animated) { completion?(()) }
        case .push:
            navigationController?.popViewController(animated: animated)
        }
    }
}
