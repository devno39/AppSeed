//
//  ToastHelper.swift
//  AppSeed
//
//  Created by Claude on 30.03.2026.
//

import UIKit
import SnapKit

enum ToastHelper {

    // MARK: - Properties
    private static weak var currentToast: ToastView?
    private static var dismissWorkItem: DispatchWorkItem?

    // MARK: - Show (Window — global)
    static func show(
        icon: String? = nil,
        title: String,
        subtitle: String? = nil,
        autoDismiss: Bool = true,
        duration: TimeInterval = 3.0
    ) {
        guard let window = UIApplication.shared.keyWindow() else { return }
        show(in: window, icon: icon, title: title, subtitle: subtitle, autoDismiss: autoDismiss, duration: duration)
    }

    // MARK: - Show (ViewController — local)
    static func show(
        on viewController: UIViewController,
        icon: String? = nil,
        title: String,
        subtitle: String? = nil,
        autoDismiss: Bool = true,
        duration: TimeInterval = 3.0
    ) {
        let targetView = viewController.navigationController?.view ?? viewController.view!
        show(in: targetView, icon: icon, title: title, subtitle: subtitle, autoDismiss: autoDismiss, duration: duration)
    }

    // MARK: - Dismiss
    static func dismiss() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil

        guard let toast = currentToast else { return }
        currentToast = nil

        let clearance = toast.bounds.height + (toast.superview?.safeAreaInsets.top ?? 0) + 24

        UIView.animate(withDuration: 0.3, animations: {
            toast.transform = CGAffineTransform(translationX: 0, y: -clearance)
            toast.alpha = 0
        }) { _ in
            toast.removeFromSuperview()
        }
    }

    // MARK: - Show (View — direct)
    static func show(
        in view: UIView,
        icon: String?,
        title: String,
        subtitle: String?,
        autoDismiss: Bool,
        duration: TimeInterval
    ) {
        dismiss()

        let toast = ToastView(icon: icon, title: title, subtitle: subtitle)
        view.addSubview(toast)

        toast.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }

        view.layoutIfNeeded()
        currentToast = toast

        let offScreen = toast.bounds.height + view.safeAreaInsets.top + 8
        toast.transform = CGAffineTransform(translationX: 0, y: -offScreen)

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            toast.transform = .identity
        }

        guard autoDismiss else { return }

        let workItem = DispatchWorkItem { dismiss() }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }
}
