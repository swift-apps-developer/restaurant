//
//  Category.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object, Codable {
    @objc dynamic var id = Int()
    @objc dynamic var name = String()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

struct CategoryList: Codable {
    let categories: [String]
}

