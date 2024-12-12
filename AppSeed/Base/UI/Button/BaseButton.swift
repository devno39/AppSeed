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
    
    var style: Style?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        prepare()
    }
    
    // MARK: - Prepare
    private func prepare() {
        titleLabel?.font = style?.font
        setTitleColor(style?.textColor, for: .normal)
        backgroundColor = style?.backgroundColor
        roundCorners(radius: 16)
    }
}

// MARK: - Style
extension BaseButton {
    enum Style {
        case primary
        
        var font: UIFont {
            switch self {
            case .primary:
                return .systemFont(ofSize: 16, weight: .bold)
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .primary:
                return ColorText.textPrimary.color
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .primary:
                return Palette.palette1.color
            }
        }
    }
}
