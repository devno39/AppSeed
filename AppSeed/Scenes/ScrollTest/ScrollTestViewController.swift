//
//  ViewControllerTemplate.swift
//  AppSeed
//
//  Created by Tunay Alver on 17.11.2024.
//

import UIKit
import SnapKit

final class ScrollTestViewController: BaseViewController<ScrollTestViewModel, ScrollTestRouter> {
    // MARK: - Properties
    override var isScrollable: Bool { true }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Prepare
    override func prepare() {
        super.prepare()
        draw()
        prepareScrollView()
    }
    
    private func prepareScrollView() {
        let rows = (1...16).map { _ in RowTest() }
        addToScrollView(rows)
        setScrollViewStackSpacing(16)
        setScrollViewInsets(top: 16, bottom: 16)
        setScrollViewStackInsets(left: 16, right: 16)
    }

    // MARK: - Bind
    override func bindViewModel() {
        super.bindViewModel()
    }
}

// MARK: - Draw
private extension ScrollTestViewController {
    private func draw() {}
}

class RowTest: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    init() {
        super.init(frame: .zero)
        prepare()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCornersWithShadow(radius: 12, color: randomColor(), opacity: 0.5)
    }
    
    private func prepare() {
        backgroundColor = randomColor()
        snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
    }
    
    private func randomColor() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1),
                       green: CGFloat.random(in: 0...1),
                       blue: CGFloat.random(in: 0...1),
                       alpha: 1.0)
    }
}
