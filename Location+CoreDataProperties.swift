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
    
    var photoURL:URL {
        assert(photoID != nil, "No photo ID set")
        let filename =  "Photo-\(photoID!.int32Value).jpg"
        let fileURL = applicationDocumentsDirectory.appendingPathComponent(filename)
        
        return fileURL
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    func removePhotoFile(){
        if hasPhoto {
            let path = photoURL.path
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: path) {
                do {
                    try fileManager.removeItem(atPath: path)
                } catch {
                    print("Error removing file: \(error)")
                }
            }
        }
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID")
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        
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
