//
//  UIViewController+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 26.08.2024.
//

import UIKit

public extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
    
    func totalTopBarHeight() -> CGFloat {
        let statusBarHeight = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.statusBarManager?.statusBarFrame.height ?? 0
        
        let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 44
        
        return statusBarHeight + navBarHeight
    }
}
