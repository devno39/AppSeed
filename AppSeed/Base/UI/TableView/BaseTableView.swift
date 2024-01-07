//
//  BaseTableView.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

class BaseTableView: UITableView {
    // MARK: - Init
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        prepare()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        prepare()
    }
    
    // MARK: - Prepare
    func prepare() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        separatorStyle = .none
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
    }
}
