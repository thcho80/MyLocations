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
    @NSManaged public var photoID:NSNumber?

    var hasPhoto:Bool {
        return photoID != nil
    }
    
    var photoPath:URL {
        assert(photoID != nil, "No photo ID set")
        let filename =  "Photo-\(photoID!.int32Value).jpg"
        
        let storeURL = applicationDocumentsDirectory.appendingPathComponent(filename)
        
  print(storeURL)
        
        return storeURL
        
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath.absoluteString)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID")
        print("before : \(currentID)")
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        
        print("before : \(currentID)")
        return currentID
       
        
    }

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
