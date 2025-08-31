//
//  NSMutableAttributedString+Extension.swift
//  AppSeed
//
//  Created by tunay alver on 30.08.2025.
//

import Foundation

extension NSMutableAttributedString {
    func addLink(to text: String, url: String) {
        if let range = (self.string as NSString?)?.range(of: text),
           range.location != NSNotFound {
            self.addAttribute(.link, value: url, range: range)
        }
    }
}
