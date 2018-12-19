//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by human on 2018. 12. 13..
//  Copyright © 2018년 com.humantrion. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation
import MapKit

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: NSDate?
    @NSManaged public var locationDescription: String?
    @NSManaged public var category: String?
    @NSManaged public var placemark: CLPlacemark?

}

extension Location: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title: String? {
        if let locationDescription = locationDescription {
            return locationDescription
        } else {
            return "(No Description)"
        }
//        if (locationDescription?.isEmpty)! {
//            return "(No Description)"
//        }else {
//            print(locationDescription!)
//
//            return locationDescription
//        }
    }

    public var subtitle: String? {
        return category
    }
    
}
