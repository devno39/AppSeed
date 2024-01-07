//
//  HudView.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit
import Lottie
import SnapKit

final class HudView: UIView {
    // MARK: - Properties
    private lazy var lottieView: LottieAnimationView = {
        let view = LottieAnimationView(name: "lottie-loading")
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        return view
    }()
    
    private lazy var logo: CircleImageView = {
        let view = CircleImageView(frame: .zero)
        view.image = Logo.logo_1024.image
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        draw()
        prepare()
        lottieView.play()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        draw()
        prepare()
        lottieView.play()
    }
    
    func prepare() {
        let backgroundColor = ColorBackground.backgroundPrimary.color
        self.backgroundColor = backgroundColor.withAlphaComponent(0.5)
    }
}

private extension HudView {
    private func draw() {
        addSubview(lottieView)
        lottieView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        addSubview(logo)
        logo.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
}
