//
//  BaseTableViewCell.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

class BaseTVCell: UITableViewCell, ReusableView {
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
    private func prepare() {
        selectionStyle = .none
    }
}
