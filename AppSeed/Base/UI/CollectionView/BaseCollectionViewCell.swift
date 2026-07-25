//
//  BaseCollectionViewCell.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell, ReusableView, PaletteUpdatable {
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
    func prepare() {}

    // MARK: - PaletteUpdatable
    @objc dynamic func updatePaletteColors() {}
}
