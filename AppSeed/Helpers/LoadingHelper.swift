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
    private var activeRequestsCount = 0
    private let lock = NSLock()
    
    private init() { }
    
    func showLoading() {
        lock.lock()
        defer { lock.unlock() }
        
        activeRequestsCount += 1
        guard activeRequestsCount == 1 else { return }
        
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
        lock.lock()
        defer { lock.unlock() }

        if activeRequestsCount == 0 {
            #if DEBUG
            assertionFailure("🛑 hideLoading() called more than showLoading()")
            #endif
            return
        }
        
        activeRequestsCount = max(0, activeRequestsCount - 1)
        guard activeRequestsCount == 0 else { return }

        DispatchQueue.main.async {
            self.hudView?.removeFromSuperview()
            self.hudView = nil
        }
    }
}
