//
//  MenuItem.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation


struct MenuItem: Codable {
    var id: Int
    var name: String
    var detailText: String
    var price: Double
    var category: String
    var imageURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case detailText = "description"
        case price
        case category
        case imageURL = "image_url"
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
