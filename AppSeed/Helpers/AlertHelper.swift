//
//  AlertHelper.swift
//  AppSeed
//
//  Created by tunay alver on 13.07.2025.
//

import UIKit

final class AlertHelper {
    private static func topViewController() -> UIViewController? {
        return UIApplication.shared.keyWindow()?.rootViewController?.topMostViewController()
    }
    
    static func showAlert(
        style: UIAlertController.Style = .alert,
        title: String? = nil,
        message: String? = nil,
        hideOnOutsideTap: Bool = true,
        primaryTitle: String = Localizable.ok,
        secondaryTitle: String? = nil,
        primaryAction: EmptyClosure? = nil,
        secondaryAction: EmptyClosure? = nil
    ) {
        guard let topVC = topViewController() else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        // TODO: - if not needed remove
        alert.overrideUserInterfaceStyle = .dark
        
        let primaryButton = UIAlertAction(title: primaryTitle, style: .default) { _ in
            primaryAction?()
        }
        alert.addAction(primaryButton)
        
        if let secondaryTitle, !secondaryTitle.isEmpty {
            let secondaryButton = UIAlertAction(title: secondaryTitle, style: .default) { _ in
                secondaryAction?()
            }
            alert.addAction(secondaryButton)
        }
        
        if style == .actionSheet {
            let cancelButton = UIAlertAction(title: Localizable.cancel, style: .cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelButton)
            
            // iPad
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = topVC.view
                popoverController.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        DispatchQueue.main.async {
            topVC.present(alert, animated: true) {
                alert.setTapOutsideToDismiss(hideOnOutsideTap)
            }
        }
    }
}

extension UIAlertController {
    func setTapOutsideToDismiss(_ hideOnOutsideTap: Bool = true) {
        guard hideOnOutsideTap else { return }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAlert))
        tapGesture.cancelsTouchesInView = true
        view.superview?.subviews.first?.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissAlert() {
        dismiss(animated: true, completion: nil)
    }
}
