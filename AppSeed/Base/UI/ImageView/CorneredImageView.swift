//
//  CorneredImageView.swift
//  AppSeed
//
//  Created by tunay alver on 24.11.2024.
//


import UIKit

@IBDesignable
class CorneredImageView: BaseImageView {
    
    @IBInspectable
    var cornerRadius: CGFloat = 16
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepare()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        awakeFromNib()
    }
    
    // MARK: - Prepare
    private func prepare() {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}
