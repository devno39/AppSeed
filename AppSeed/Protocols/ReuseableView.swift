//
//  ReuseableView.swift
//  AppSeed
//
//  Created by tunay alver on 15.09.2023.
//

import UIKit

protocol ReusableView: AnyObject {
    static var identifier: String { get }
}

extension ReusableView where Self: UIView {
    static var identifier: String {
        return String(describing: self)
    }
}
