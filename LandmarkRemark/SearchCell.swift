//
//  SearchCell.swift
//  LandmarkRemark
//
//  Created by Haidar Mohammed on 7/11/18.
//  Copyright © 2018 Haidar AlOgaily. All rights reserved.
//

import UIKit
import CoreLocation
class SearchCell: UITableViewCell {

    //get IBOutlets
    @IBOutlet var title: UILabel!
    @IBOutlet var discription: UILabel!

    //a location variable to determine which note it is when clicked in the search
    var location : CLLocationCoordinate2D!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //customizing the frame of each tableview cell to be smaller in height and width
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.y += 5
            frame.size.height -= 2 * 5
            frame.origin.x += 10
            frame.size.width -= 4 * 5
            super.frame = frame
        }
    }
}
