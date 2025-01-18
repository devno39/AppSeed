//
//  LoadingHelper.swift
//  AppSeed
//
//  Created by tunay alver on 18.01.2025.
//

import UIKit
import SnapKit

final class LoadingHelper {
    
    static let shared = LoadingHelper()
    
    private var hudView: HudView?
    
    private init() { }
    
    func showLoading() {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow()
            let newHudView = HudView()
            self.hudView = newHudView
            window?.addSubview(newHudView)
            newHudView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.hudView?.removeFromSuperview()
            self.hudView = nil
        }
    }
}
