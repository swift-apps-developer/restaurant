//
//  PreparationTime.swift
//  restaurant
//
//  Created by love on 5/16/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation


struct PreparationTime: Codable {
    let prepareTime: Int
    
    enum ResultKeys: String, CodingKey {
        case prepareTime = "preparation_time"
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy:
            ResultKeys.self)
        
        self.prepareTime = try valueContainer.decode(Int.self,
                                            forKey: ResultKeys.prepareTime)
    }
}
