//
//  ProgressCircleView.swift
//  AppSeed
//
//  Created by tunay alver on 20.10.2023.
//

import UIKit

final class ProgressCircleView: UIView {
    // MARK: - Properties
    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var initialTimeString: String!
    var timeString: String?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - LifeCycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        ProgressCircleDrawer.draw(frame: bounds,
                                  progress: progress,
                                  timeString: timeString ?? initialTimeString)
    }
}
