//
//  ViewControllerTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit
import SnapKit

final class TutorialViewController: BaseViewController<TutorialViewModel, TutorialRouter> {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        draw()
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
    }
}

// MARK: - Draw
private extension TutorialViewController {
    private func draw() {}
}
