//
//  CircleImageView.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

class CircleImageView: UIImageView {
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        prepare()
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        roundCorners(radius: frame.height / 2)
    }
    
    // MARK: - Prepare
    private func prepare() {}
}
