//
//  DroppablePin.swift
//  be-in-city
//
//  Created by sHiKoOo on 2/19/19.
//  Copyright © 2019 sHiKoOo. All rights reserved.
//

import UIKit
import MapKit

// create custom pin at the location where we touch
class DroppablePin: NSObject, MKAnnotation {
    
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()  // to use it as initiallizer of custom pin
    }
    
}
