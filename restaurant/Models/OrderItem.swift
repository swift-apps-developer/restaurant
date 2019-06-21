//
//  OrderItem.swift
//  restaurant
//
//  Created by love on 6/21/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class OrderItem: Object {
    @objc dynamic var id = Int()
    @objc dynamic var menuItem: MenuItem?
    @objc dynamic var count = Int()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(menuItem: MenuItem, count: Int = 1) {
        self.init()
        self.menuItem = menuItem
        self.count = count
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
