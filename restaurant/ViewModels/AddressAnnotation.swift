//
//  AddressAnnotation.swift
//  restaurant
//
//  Created by love on 6/23/19.
//  Copyright © 2019 love. All rights reserved.
//

import Foundation
import MapKit

class AddressAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}
