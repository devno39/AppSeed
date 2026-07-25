//
//  SplashViewController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit
import SnapKit

final class SplashViewController: BaseViewController<SplashViewModel, SplashRouter> {

    // MARK: - UI
    private lazy var bgImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.image = BackgroundImages.bg_launch.image
        return imageView
    }()

    private lazy var splashImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = Logo.logo_1024.image
        return imageView
    }()

    private lazy var splashTitle: UILabel = {
        let label = UILabel()
        label.text = SplashLocalizable.splash_title
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = ColorText.textPrimary.color
        label.textAlignment = .center
        return label
    }()

    // MARK: - Properties
    private var foregroundObserver: NSObjectProtocol?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        EmojiHelper.warmup()
        startWhenForeground()
    }

    deinit {
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        splashImage.roundCorners(radius: 64)
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        view.backgroundColor = ColorBackground.backgroundPrimary.color
        draw()
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
        viewModel?.groupClosure = { [weak self] in
            guard let self else { return }
            routeToNext()
        }
    }

    // MARK: - Functions
    func mainRequest() {
        viewModel?.requestFake()
    }

    // Silent push can cold-launch the app in the background; routing from there is dropped
    // (no foreground scene) and the splash sticks forever. Run the flow only in foreground.
    // Scene connect reports .background even on a normal icon launch, so this defers every
    // cold launch — willEnterForeground fires moments later and resumes the flow.
    private func startWhenForeground() {
        guard UIApplication.shared.applicationState == .background else {
            checkUpdate()
            return
        }
        log(.info, .general, "Splash: scene connected in background — deferring flow to foreground (normal on cold launch)")
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            if let observer = foregroundObserver {
                NotificationCenter.default.removeObserver(observer)
                foregroundObserver = nil
            }
            checkUpdate()
        }
    }

    private func checkUpdate() {
        viewModel?.checkUpdate() { [weak self] needs in
            guard let self else { return }
            if needs {
                observeForegroundForRecheck()
                // Returning from the App Store without updating lands here again — don't
                // stack a second alert on the one still presented.
                guard presentedViewController == nil else { return }
                AlertHelper.showAlert(
                    title: SplashLocalizable.update_title,
                    message: SplashLocalizable.update_message,
                    primaryTitle: SplashLocalizable.update_button,
                    secondaryTitle: nil,
                    primaryAction: {
                        UIApplication.shared.openAppStore()
                    }
                )
            } else {
                if let observer = foregroundObserver {
                    NotificationCenter.default.removeObserver(observer)
                    foregroundObserver = nil
                }
                viewModel?.afterCheckUpdate()
            }
        }
    }

    private func observeForegroundForRecheck() {
        guard foregroundObserver == nil else { return }
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkUpdate()
        }
    }

    // MARK: - Route
    private func routeToNext() {
        if !UserDefaultsWrapper.tutorials_seen {
            router?.showTutorial()
        } else if viewModel?.isUserLoggedIn ?? false {
            router?.showLogin() // commit 3 wires TabBarRoute → showTabBar()
        } else {
            router?.showLogin()
        }
    }
}

// MARK: - Draw
extension SplashViewController {

    private func draw() {
        view.addSubview(bgImage)
        bgImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        view.addSubview(splashImage)
        splashImage.snp.makeConstraints {
            $0.width.height.equalTo(128)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(view.safeAreaLayoutGuide)
        }

        view.addSubview(splashTitle)
        splashTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(splashImage.snp.bottom).offset(8)
        }
    }
}
