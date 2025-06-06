//
//  BaseCollectionViewCell.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell, ReusableView {
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepare()
    }
    
    // MARK: - Prepare
    private func prepare() {}
}
