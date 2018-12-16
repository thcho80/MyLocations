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
