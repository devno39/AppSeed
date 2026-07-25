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
        observePaletteChange()
        interactivePopGestureRecognizer?.delegate = self
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Push
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        topViewController?.navigationItem.backBarButtonItem = NoMenuBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        super.pushViewController(viewController, animated: animated)
    }

    // MARK: - Prepare
    private func prepare() {
        setBarAppearance()
    }

    // MARK: - Palette
    private func observePaletteChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePaletteChange),
            name: .paletteDidChange,
            object: nil
        )
    }

    @objc private func handlePaletteChange() {
        navigationBar.tintColor = Palette.palette1.color
    }

    // MARK: - Private
    private func setBarAppearance() {
        if #available(iOS 26, *) {
            setGlassAppearance()
        } else {
            setClassicAppearance()
        }

        navigationBar.tintColor = Palette.palette1.color
    }

    @available(iOS 26, *)
    private func setGlassAppearance() {
        // Let the system apply Liquid Glass — don't override background
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        let titleFont: UIFont = {
            if let d = UIFont.systemFont(ofSize: 17, weight: .semibold).fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: d, size: 17)
            }
            return .systemFont(ofSize: 17, weight: .semibold)
        }()
        let largeTitleFont: UIFont = {
            if let d = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: d, size: 34)
            }
            return .systemFont(ofSize: 34, weight: .bold)
        }()

        appearance.titleTextAttributes = [
            .foregroundColor: ColorText.textPrimary.color,
            .font: titleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: ColorText.textPrimary.color,
            .font: largeTitleFont
        ]

        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]
        appearance.backButtonAppearance = backButtonAppearance

        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }

    private func setClassicAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ColorBackground.backgroundPrimary.color

        let titleFont: UIFont = {
            if let d = UIFont.systemFont(ofSize: 17, weight: .semibold).fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: d, size: 17)
            }
            return .systemFont(ofSize: 17, weight: .semibold)
        }()
        let largeTitleFont: UIFont = {
            if let d = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: d, size: 34)
            }
            return .systemFont(ofSize: 34, weight: .bold)
        }()

        appearance.titleTextAttributes = [
            .foregroundColor: ColorText.textPrimary.color,
            .font: titleFont
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: ColorText.textPrimary.color,
            .font: largeTitleFont
        ]

        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]
        appearance.backButtonAppearance = backButtonAppearance

        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
}

// MARK: - UIGestureRecognizerDelegate
// Keep edge-swipe alive when a custom leftBarButtonItem hides the back button — but only past the root VC to avoid a freeze.
extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

// MARK: - NoMenuBarButtonItem
// The system rebuilds the back button's long-press history menu after assignment — overriding the setter is the only reliable off switch.
final class NoMenuBarButtonItem: UIBarButtonItem {
    override var menu: UIMenu? {
        get { nil }
        set { }
    }
}
