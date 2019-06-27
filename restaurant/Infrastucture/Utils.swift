//
//  Utils.swift
//  restaurant
//
//  Created by love on 6/24/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


extension UIViewController {
    func setNavBarStyle() {
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "#ffd80c")
    }
    
    func setNavBarTitle(title: String) {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        titleLabel.font = UIFont(name: "Font Awesome 5 Free", size: 18.0)!
        titleLabel.text = title
        titleLabel.textColor = UIColor(hexString: "#026670")
        navigationItem.titleView = titleLabel
        self.title = title
    }
}
