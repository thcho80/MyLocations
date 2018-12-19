//
//  MapViewController.swift
//  MyLocations
//
//  Created by human on 2018. 12. 18..
//  Copyright © 2018년 com.humantrion. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView:MKMapView!
    
    var managedObjectContext:NSManagedObjectContext!
    
    var locations = [Location]()
    
    @IBAction func showUser (){
        let region = MKCoordinateRegion.init(center: mapView!.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func showLocation(){
        let region = regionForAnnotation(annotations: locations)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateLocations()
        
        if !locations.isEmpty {
            showLocation()
        }
    }
    

    func updateLocations(){
        
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        fetchRequest.entity = entity
        
        do {
            let foundObject = try managedObjectContext.fetch(fetchRequest)
            mapView.removeAnnotations(locations)
            locations = foundObject as! [Location]
            mapView.addAnnotations(locations)
                       
        } catch {
            fatalCoreDataError(error: error as NSError)
        }
        
        
    }
    
    func regionForAnnotation(annotations:[MKAnnotation])->MKCoordinateRegion {
        
        var region:MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion.init(center: mapView!.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion.init(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2DMake(34, 127)
            var bottomRightCoord = CLLocationCoordinate2DMake(40, 124)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2DMake(topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2
                                                    ,topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.1
            
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace
                                        , longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
    
    @objc func showLocationDetails(_:UIButton) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is Location {
            
            //TODO: - !!!
            let identifier = "Location"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation , reuseIdentifier: identifier)
                
                annotationView!.isEnabled = true
                annotationView!.canShowCallout = true
                annotationView!.animatesDrop = true
                annotationView!.pinTintColor = .green
                
                let rightButton = UIButton.init(type: .detailDisclosure)
                rightButton.addTarget(self, action: #selector(MapViewController.showLocationDetails(_:)), for: .touchUpInside)
                annotationView!.rightCalloutAccessoryView = rightButton
            } else {
                annotationView!.annotation = annotation
            }

            let button = annotationView!.rightCalloutAccessoryView as! UIButton
            
            if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
            return annotationView
        }
        return nil
    }
}
