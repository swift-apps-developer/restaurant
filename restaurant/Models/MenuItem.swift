//
//  MenuItem.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


class MenuItem: Object, Codable {
    @objc dynamic var id = Int()
    @objc dynamic var name = String()
    @objc dynamic var detailText = String()
    @objc dynamic var price = Double()
    @objc dynamic var category = String()
    @objc dynamic var imageURL = String()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case detailText = "description"
        case price
        case category
        case imageURL = "image_url"
    }
    
    convenience init(id: Int, name: String, detailText: String, price: Double, category: String, imageURL: String) {
        self.init()
        self.id = id
        self.name = name
        self.detailText = detailText
        self.price = price
        self.category = category
        self.imageURL = imageURL
        
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
    
//    init(from decoder: Decoder) throws {
//        let valueContainer = try decoder.container(keyedBy:
//            ResultKeys.self)
//
//        self.id = try valueContainer.decode(Int.self,
//                                            forKey: ResultKeys.id)
//        self.name = try
//            valueContainer.decode(String.self, forKey:
//                ResultKeys.name)
//
//        self.detailText = try?
//            valueContainer.decode(String.self, forKey:
//                ResultKeys.detailText)
//
//        self.price = try
//            valueContainer.decode(Double.self, forKey:
//                ResultKeys.price)
//
//        self.category = try valueContainer.decode(String.self, forKey:
//            ResultKeys.category)
//
//        self.imageURL = try valueContainer.decode(URL.self, forKey:
//            ResultKeys.imageURL)
//    }
}
