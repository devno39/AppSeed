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
    private lazy var splashImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = Logo.logo_1024.image
        imageView.roundCorners(radius: 16)
        return imageView
    }()
    private lazy var splashTitle: UILabel = {
        let label = UILabel()
        let text = SplashLocalizable.splash_title
        label.text = text
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = ColorText.textPrimary.color
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainRequest()
    }
    
    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        view.backgroundColor = ColorBackground.backgroundSecondary.color
        draw()
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
        viewModel?.requestClosure = { [weak self] in
            guard let self else { return }
            routeTutorial()
        }
    }
    
    // MARK: - Functions
    func mainRequest() {
        viewModel?.request()
    }

    // MARK: - Route
    private func routeTutorial() {
        router?.showTutorial()
    }
}

// MARK: - Draw
private extension SplashViewController {
    private func draw() {
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
