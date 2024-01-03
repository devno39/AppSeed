//
//  BaseTabbarController.swift
//  AppSeed
//
//  Created by tunay alver on 10.08.2023.
//

import UIKit

// TODO: - Update when needed
class BaseTabbarController: UITabBarController, UITabBarControllerDelegate {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepare()
    }
    
    //MARK: - Prepare
    func prepare() {
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.clipsToBounds = false
        tabBar.backgroundColor = ColorBackground.backgroundPrimary.color
        tabBar.tintColor = ColorText.textPrimary.color
        tabBar.unselectedItemTintColor = ColorText.textPrimary.color
        definesPresentationContext = true
    }
}
