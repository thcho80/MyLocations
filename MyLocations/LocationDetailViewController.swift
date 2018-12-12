//
//  LocationDetailViewController.swift
//  MyLocations
//
//  Created by human on 2018. 12. 11..
//  Copyright © 2018년 com.humantrion. All rights reserved.
//

import UIKit
import CoreLocation

private let dateFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailViewController:UITableViewController {
    
    @IBOutlet weak var descriptionTextView:UITextView!
    @IBOutlet weak var categoryLabel:UILabel!
    @IBOutlet weak var latitudeLabel:UILabel!
    @IBOutlet weak var longitudeLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    @IBOutlet weak var dateLabel:UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark:CLPlacemark?
    
    var descriptionText = ""
    
    var categoryName = "No Category"
    
    // MARK: - LocationDetailViewController initialization
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = formatDate(date: NSDate())
    }
    
    // MARK: - Navigation Bar
    
    @IBAction func done(){
        print("DescriptionText: \(descriptionText)")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(){
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Util Functions
    func stringFromPlacemark(placemark:CLPlacemark) -> String {
        print("placemark \(placemark)")
        
        return "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? "")" +
        " \(placemark.locality ?? "") \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? "") \(placemark.country ?? "")"
        
    }
    
    func formatDate(date:NSDate)->String {
        return dateFormatter.string(from: date as Date)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2{
            addressLabel.frame.size = CGSize(width:view.bounds.size.width - 115, height:10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        } else {
            return 44
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCatagoryName = categoryName
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue){
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCatagoryName
        categoryLabel.text = categoryName
    }
    
}

extension LocationDetailViewController:UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        descriptionText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        descriptionText = textView.text
    }
}
