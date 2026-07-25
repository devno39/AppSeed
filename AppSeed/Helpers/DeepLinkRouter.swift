//
//  DeepLinkRouter.swift
//  AppSeed
//
//  Created by Claude on 25.07.2026.
//

import UIKit

// Template deep-link router: guards the app's URL scheme, maps an allowlist
// of hosts to tab indices, and survives the cold-launch race (capture the URL
// before the tab bar is root, drain it once setToWindow installs the tab bar).
// Extend DeepLinkHost per app; keep the scheme in sync with Info.plist's
// CFBundleURLTypes.
final class DeepLinkRouter {
    static let shared = DeepLinkRouter()
    private init() {}

    private static let scheme = "appseed"

    // Cold-launch URL captured before the tab bar is root; drained once the tab
    // bar takes over. Consume-on-read (drain nils it before routing) so a URL
    // cannot leak across sign-out boundaries.
    private var pendingURL: URL?

    // Allowlist — unknown hosts are logged + dropped (defense in depth).
    private enum DeepLinkHost: String {
        case home

        var tabIndex: Int {
            switch self {
            case .home: return 0
            }
        }
    }

    // MARK: - Capture (cold launch)
    func capture(from options: UIScene.ConnectionOptions) {
        if let url = options.urlContexts.first?.url {
            pendingURL = url
        }
        log(.info, .general, "DeepLinkRouter capture — pendingURL=\(pendingURL?.absoluteString ?? "nil")")
    }

    // MARK: - Handle (warm)
    func handle(url: URL) {
        route(url: url)
    }

    // MARK: - Drain (after window swap to tab bar)
    func drainPending() {
        guard let url = pendingURL else { return }
        pendingURL = nil
        log(.info, .general, "DeepLinkRouter drain: routing \(url.absoluteString)")
        route(url: url)
    }

    // MARK: - Route
    private func route(url: URL) {
        guard url.scheme == Self.scheme, let hostString = url.host else { return }

        guard let host = DeepLinkHost(rawValue: hostString) else {
            log(.warning, .general, "DeepLinkRouter dropped — unknown host: \(hostString)")
            return
        }

        // Splash still root on cold-launch — hold until setToWindow drains.
        guard let tabBar = UIApplication.shared.sceneDelegate?.window?.rootViewController as? UITabBarController else {
            log(.info, .general, "DeepLinkRouter: tab bar not yet root, deferring \(url.absoluteString)")
            pendingURL = url
            return
        }

        log(.info, .general, "DeepLinkRouter routing: \(url.absoluteString)")
        tabBar.selectedIndex = host.tabIndex
    }
}
