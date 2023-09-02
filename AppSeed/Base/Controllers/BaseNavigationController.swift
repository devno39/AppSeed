//
//  BaseNavigationController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepare()
    }
    
    //MARK: - Prepare
    private func prepare() {
        setBarApperance()
    }

    //MARK: - Private
    private func setBarApperance() {
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.backgroundPrimary
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.textPrimary]

        UINavigationBar.appearance().tintColor = .palette2
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
}
