//
//  UIStackView+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2025.
//

import UIKit

extension UIStackView {
    func removeArrangedSubviews() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
}
