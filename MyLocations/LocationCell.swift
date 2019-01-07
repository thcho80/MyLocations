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
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = UIColor.black
        descriptionLabel.textColor = UIColor.white
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
//        descriptionLabel.backgroundColor = UIColor.red
//        addressLabel.backgroundColor = UIColor.red
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let sv = superview {
            descriptionLabel.frame.size.width = sv.frame.size.width - descriptionLabel.frame.origin.x - 10
            addressLabel.frame.size.width = sv.frame.size.width - addressLabel.frame.origin.x - 10
        }
    }
    
    func configureForLocation(location:Location){
        
        if (location.locationDescription?.isEmpty)! {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            var text = ""
            text.addText(text: placemark.subThoroughfare)
            text.addText(text: placemark.thoroughfare, withSeparator: " ")
            text.addText(text: placemark.locality, withSeparator: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f Long: %.8f", location.latitude, location.longitude)
        }
        
        photoImageView.image = imageForLocation(location: location)
        
    }
    
    func imageForLocation(location:Location)->UIImage {
        if location.hasPhoto {
            if let image = location.photoImage {
                return image.resizedImageWithBounds(bounds: CGSize(width: 52, height: 52))
            }
        }
        return UIImage(named: "No Photo")!
    }

}
