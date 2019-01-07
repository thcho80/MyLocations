//
//  FirstViewController.swift
//  MyLocations
//
//  Created by human on 2018. 12. 7..
//  Copyright © 2018년 com.humantrion. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import QuartzCore

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate, CAAnimationDelegate{

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var containerView:UIView!
    
    let locationManager = CLLocationManager()
    var location:CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    
    //MARK: reverse geocoding variable
    let geocoder = CLGeocoder()
    var placemark:CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError:NSError?
    var timer:Timer?
    
    var managedObjectContext:NSManagedObjectContext!
    
    var logoVisible = false
    
    lazy var logoButton = { () -> UIButton in
        let button = UIButton(type: .custom) as UIButton
        button.setBackgroundImage(UIImage(named: "Logo"), for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(CurrentLocationViewController.getLocation), for: .touchUpInside)
        button.center.x = self.view.bounds.midX
        button.center.y = 220
        
        return button
    }()
    
    //MARK: - init method
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        setNeedsStatusBarAppearanceUpdate()
        
    }
    
    @IBAction func getLocation(){
        print(#function)
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
        configureGetButton()
        
        if logoVisible {
            hideLogoView()
        }
    }
    
    //MARK: - locationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation:CLLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            print("newLocation.timestamp.timeIntervalSinceNow < -5 \(newLocation.timestamp.timeIntervalSinceNow < -5)")
            return
        }

        if newLocation.horizontalAccuracy < 0 {
            print("newLocation.horizontalAccuracy < 0 \(newLocation.horizontalAccuracy < 0 )")
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
            print("distance: \(distance)")
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            updateLabels()
           
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We 're done!")
                stopLocationManager()
                configureGetButton()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            //Reverse Geocoding code begin
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(location!, completionHandler: {
                    placemarks, error in
                    print("** Found placemarks: \(placemarks), error: \(error)")
                    
                    self.lastGeocodingError = error as NSError?
                    if error == nil && !(placemarks?.isEmpty)! {
                        self.placemark = placemarks?.last
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        } else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        
        if error._code == CLError.locationUnknown.rawValue{
            return
        }
        
        lastLocationError = error as NSError
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }


    //MARK: -
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app ins Setting",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels(){
        
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address"
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
            latitudeTextLabel.isHidden = false
            longitudeTextLabel.isHidden = false
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            tagButton.isHidden = true
            addressLabel.text = ""
            
            var statusMessage:String
            
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching.."
            } else {
                statusMessage = ""
                showLogoView()
            }
            messageLabel.text = statusMessage
            
            latitudeTextLabel.isHidden = true
            longitudeTextLabel.isHidden = true
        }
    }
    
    func showLogoView(){
        if !logoVisible {
            logoVisible = true
            containerView.isHidden = true
            view.addSubview(logoButton)
        }
    }
    
    func hideLogoView(){
        if !logoVisible {return}
        
        logoVisible = false
        containerView.isHidden = false
        
        containerView.center.x = view.bounds.size.width * 2
        containerView.center.y = 40 + containerView.bounds.height / 2
        
        let centerX = view.bounds.midX
        
        let panelMover = CABasicAnimation(keyPath: "position")
        panelMover.isRemovedOnCompletion = false
        panelMover.fillMode = CAMediaTimingFillMode.forwards
        panelMover.duration = 0.6
        panelMover.fromValue = NSValue(cgPoint: containerView.center)
        panelMover.toValue = NSValue(cgPoint: CGPoint(x: centerX, y: containerView.center.y))
        panelMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        panelMover.delegate = (self as! CAAnimationDelegate)
        containerView.layer.add(panelMover, forKey: "panelMover")
        
        let logoMover = CABasicAnimation(keyPath: "position")
        logoMover.isRemovedOnCompletion = false
        logoMover.fillMode = CAMediaTimingFillMode.forwards
        logoMover.duration = 0.5
        logoMover.fromValue = NSValue(cgPoint: logoButton.center)
        logoMover.toValue = NSValue(cgPoint: CGPoint(x: -centerX, y: logoButton.center.y))
        logoMover.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        logoMover.delegate = (self as! CAAnimationDelegate)
        logoButton.layer.add(logoMover, forKey: "logoMover")
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = CAMediaTimingFillMode.forwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        logoRotator.delegate = (self as! CAAnimationDelegate)
        logoButton.layer.add(logoRotator, forKey: "logoRotator")
 
    }

    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        containerView.layer.removeAllAnimations()
        containerView.center.x = view.bounds.size.width / 2
        containerView.center.y = 40 + containerView.bounds.size.height / 2
        
        logoButton.layer.removeAllAnimations()
        logoButton.removeFromSuperview()
    }
    
    
    func stopLocationManager(){

        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }
    
    func startLocationManager(){

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(CurrentLocationViewController.didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func configureGetButton(){
        let spinnerTag = 1099
        
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
            
            if view.viewWithTag(spinnerTag) == nil {
                let spinner = UIActivityIndicatorView(style: .white)
                spinner.center = messageLabel.center
                spinner.center.y += spinner.bounds.size.height / 2 + 15
                spinner.startAnimating()
                spinner.tag = spinnerTag
                containerView.addSubview(spinner)
            }
        } else {
            getButton.setTitle("Get My Location", for: .normal)
            
            if let spinner = view.viewWithTag(spinnerTag){
                spinner.removeFromSuperview()
            }
        }
    }
    
    //MARK: - Reverse Geocoding
    func stringFromPlacemark(placemark:CLPlacemark) -> String {
        var line = ""
        line.addText(text: placemark.subThoroughfare)
        line.addText(text: placemark.thoroughfare, withSeparator: " ")
        line.addText(text: placemark.locality, withSeparator: ", ")
        line.addText(text: placemark.administrativeArea, withSeparator: ", ")
        line.addText(text: placemark.postalCode, withSeparator: " ")
        line.addText(text: placemark.country, withSeparator: ", ")
        return line
    }
    
    @objc func didTimeOut(){
        print("*** Time out")
        
        if location == nil {
            lastLocationError = NSError(domain: "MyLocationErrorDomain", code: 1, userInfo: nil)
        }
        
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    //MARK: - segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TagLocation" {
            
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
            
        } else {
            
            print("There is no segue identifier")
            
        }
    }
}

