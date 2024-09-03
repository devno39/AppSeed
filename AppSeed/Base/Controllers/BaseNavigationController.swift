//
//  BaseNavigationController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    // MARK: - Life Cycle
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
        appearance.backgroundColor = ColorBackground.backgroundPrimary.color
        appearance.titleTextAttributes = [.foregroundColor: ColorText.textPrimary.color]
        appearance.largeTitleTextAttributes = [.foregroundColor: ColorText.textPrimary.color]

        UINavigationBar.appearance().tintColor = Palette.palette2.color
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
}
