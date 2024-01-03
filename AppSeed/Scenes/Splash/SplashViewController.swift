//
//  SplashViewController.swift
//  AppSeed
//
//  Created by tunay alver on 26.07.2023.
//

import UIKit
import SnapKit

final class SplashViewController: BaseViewController<SplashViewModel> {
    // MARK: - UI
    private lazy var progressView: ProgressCircleView = {
        let view = ProgressCircleView(frame: .zero)
        view.initialTimeString = "30"
        view.progress = 0
        return view
    }()
    
    // MARK: - Properties
    private var count = 30000 {
        didSet {
            let percentage = CGFloat(count) / 30000.0
            progressView.progress = percentage
        }
    }
    private var timer: Timer?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        print("my title is", viewModel.title ?? "")
        viewModel.getSomething()
        
//        startTest()
        showHud()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hideHud()
        }
    }
    
    override func prepare() {
        super.prepare()
        
        draw()
    }
    
    // MARK: - Private
    private func startTest() {
        timer?.invalidate()
        count = 30000
        timer = Timer.scheduledTimer(timeInterval: 0.001,
                                     target: self,
                                     selector: #selector(timerFired),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc
    private func timerFired() {
        count -= 1
        print("Count: \(count)")
        
        progressView.timeString = String(count)
        let progress = CGFloat(count) / 30000.0
        progressView.progress = progress
        
        if count == 0 {
            stopTest()
            progressView.timeString = "Time's Up!"
        }
    }

    private func stopTest() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - ViewModel Delegate
extension SplashViewController: SplashViewModelDelegate {
    func didGetSomething() {
        print("i got that")
    }
}

// MARK: - Draw
private extension SplashViewController {
    private func draw() {
//        view.addSubview(progressView)
//        progressView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview()
//            make.height.equalTo(84*2)
//            make.width.equalTo(84*2)
//        }
    }
}
