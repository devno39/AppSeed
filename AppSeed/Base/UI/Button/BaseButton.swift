//
//  BaseButton.swift
//  AppSeed
//
//  Created by tunay alver on 10.08.2023.
//

import UIKit

class BaseButton: UIButton {
    // MARK: - Properties
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1.0
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
}
