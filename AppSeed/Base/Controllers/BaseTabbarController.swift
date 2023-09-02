//
//  BaseTabbarController.swift
//  AppSeed
//
//  Created by tunay alver on 10.08.2023.
//

import UIKit

class BaseTabbarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Mid Button
    private lazy var buttonView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var button: BaseButton = {
        return BaseButton.init(type: .custom)
    }()
       
    // MARK: - Properties
    private let hasMidButton = true
    private let midButtonImage = UIImage(named: "ic_plus_bordered")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        prepare()
    }
    
    //MARK: - Prepare
    func prepare() {
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.clipsToBounds = false
        tabBar.backgroundColor = .backgroundPrimary
        tabBar.tintColor = .textPrimary
        tabBar.unselectedItemTintColor = .textPrimary
        definesPresentationContext = true
        
        addControllers()
        if hasMidButton {
            addButton()
        }
    }
    
    //MARK: - Plus Button
    func addButton() {
        buttonView.backgroundColor = .clear
        buttonView.awakeFromNib()
        
        button.setImage(midButtonImage, for: .normal)
        button.backgroundColor = .clear
        
        tabBar.addSubview(buttonView)
        
        updateButtonFrame()
    }
    
    func updateButtonFrame() {
        var buttonViewFrame: CGRect = buttonView.frame
        buttonViewFrame.size = CGSize(width: 50, height: 100)
        
        buttonViewFrame.origin.x = (tabBar.frame.size.width - buttonViewFrame.size.width) / 2
        buttonViewFrame.origin.y = CGFloat(-20)
        buttonView.frame = buttonViewFrame
        
        button.awakeFromNib()
        button.addTarget(nil, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        buttonView.addSubview(button)
        
        var frame: CGRect = button.frame
        frame.size = CGSize(width: 44, height: 44)
        
        frame.origin.x = 3
        frame.origin.y = buttonViewFrame.origin.y + 30
        button.layer.cornerRadius = 22
        
        button.frame = frame
    }
    
    @objc
    func plusButtonTapped() {
        // TODO: -
    }
    
    func addControllers() {
        // TODO: -
    }
    
    //MARK: - Tabbar functions
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return hasMidButton && viewController != tabBarController.viewControllers?[2]
    }
}
