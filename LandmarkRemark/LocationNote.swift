//
//  LocationNote.swift
//  LandmarkRemark
//
//  Created by Haidar Mohammed on 4/11/18.
//  Copyright © 2018 Haidar AlOgaily. All rights reserved.
//

import Foundation
import UIKit

struct LocationNote {
    
    var altitude : Double
    var longitude : Double
    var text : String
    
    init(altitude: Double, longitude: Double, text: String) {
        
        self.altitude = altitude
        self.longitude = longitude
        self.text = text
        
    }
    
    
}
