//
//  Order.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Order: Object {
    @objc dynamic var id = Int()
    @objc dynamic var name = String()
    @objc dynamic var createdDate = Date()
    @objc dynamic var address: Address?
    var items = List<OrderItem>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(items: List<OrderItem> = List<OrderItem>()) {
        self.init()
        self.items = items
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
    
    func generateName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self.createdDate)
    }
}
