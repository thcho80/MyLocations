//
//  LocationCellTableViewCell.swift
//  MyLocations
//
//  Created by human on 2018. 12. 17..
//  Copyright © 2018년 com.humantrion. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForLocation(location:Location){
        
        print(location)
        
        if (location.locationDescription?.isEmpty)! {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            addressLabel.text = "\(placemark.subThoroughfare!) \(placemark.thoroughfare!) \(placemark.locality as! String)"
        } else {
            addressLabel.text = String(format: "Lat: %.8f Long: %.8f", location.latitude, location.longitude)
        }
    }

}
