//
//  LocationNote.swift
//  LandmarkRemark
//
//  Created by Haidar Mohammed on 4/11/18.
//  Copyright © 2018 Haidar AlOgaily. All rights reserved.
//

import Foundation
import UIKit

// a location note which is a structure which represents each note

struct LocationNote {
    
    //has altitude, longitude and discriptive text, but the title is obtained elsewhere.
    
    var altitude : Double
    var longitude : Double
    var text : String
    
    init(altitude: Double, longitude: Double, text: String) {
        self.altitude = altitude
        self.longitude = longitude
        self.text = text
    }
    
}
