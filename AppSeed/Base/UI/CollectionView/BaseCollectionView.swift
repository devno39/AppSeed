//
//  BaseCollectionView.swift
//  AppSeed
//
//  Created by tunay alver on 4.01.2024.
//

import UIKit

class BaseCollectionView: UICollectionView {
    // MARK: - Init
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
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
    }
}
