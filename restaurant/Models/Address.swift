//
//  Address.swift
//  restaurant
//
//  Created by love on 6/23/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import MapKit
import Realm
import RealmSwift

class Address: Object, Codable {
    @objc dynamic var id = Int()
    @objc dynamic var title = String()
    @objc dynamic var fullName = String()
    @objc dynamic var phoneNumber = String()
    @objc dynamic var address = String()
    @objc dynamic var longitude = Double()
    @objc dynamic var latitude = Double()
    @objc dynamic var createdDate = Date()
    @objc dynamic var isDefault = true
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(title: String, fullName: String, phoneNumber: String, address: String, longitude: Double, latitude: Double) {
        self.init()
        self.title = title
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.address = address
        self.longitude = longitude
        self.latitude = latitude
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
