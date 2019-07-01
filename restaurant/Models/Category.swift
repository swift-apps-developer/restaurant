//
//  Category.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Category: Object, Codable {
    @objc dynamic var id = Int()
    @objc dynamic var name = String()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: Int, name: String) {
        self.init()
        self.id = id
        self.name = name
    }
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}

struct CategoryList: Codable {
    let categories: [String]
}

