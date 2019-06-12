//
//  Order.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation

struct Order: Codable{
    var items: [MenuItem]
    
    init(items: [MenuItem] = []) {
        self.items = items
    }
}
