//
//  BaseTableViewCell.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

class BaseTVCell: UITableViewCell, ReusableView, PaletteUpdatable {
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        prepare()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        prepare()
    }

    // MARK: - Prepare
    func prepare() {
        selectionStyle = .none
    }

    // MARK: - PaletteUpdatable
    @objc dynamic func updatePaletteColors() {}
}
