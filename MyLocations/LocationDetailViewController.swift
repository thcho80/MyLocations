//
//  LocationDetailViewController.swift
//  MyLocations
//
//  Created by human on 2018. 12. 11..
//  Copyright © 2018년 com.humantrion. All rights reserved.
//

import UIKit
import CoreLocation
import Dispatch
import CoreData

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
    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var addPhotoLabel:UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark:CLPlacemark?
    var descriptionText = ""
    var categoryName = "No Category"
    var date = NSDate()
    var managedObjectContext: NSManagedObjectContext!
    var locationToEdit:Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription!
                categoryName = location.category!
                date = location.date!
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var imageHeight:Int!
    let imageWidth = 260
    
    var image:UIImage?{
        didSet {
            if let image = image {
                
                let ratio = image.size.height / image.size.width
                imageHeight =  Int(260 * ratio)
                
                imageView.image = image
                imageView.isHidden = false
                imageView.frame = CGRect(x: 10, y: 10, width: imageWidth, height: imageHeight)
                addPhotoLabel.isHidden = true
            }
        }
    }
    
    var observer:AnyObject!
    
    // MARK: - LocationDetailViewController initialization
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if locationToEdit != nil {
            title = "Edit Location"
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = formatDate(date: date)
        
        let gestureRecognizer = UIGestureRecognizer(target: self, action: #selector(LocationDetailViewController.hideKeyboard(gestureRecognizer:)))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        listenForBackgroundNotification()
    }

    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer)
    }
    
    @objc func hideKeyboard(gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath?.section == 0 && indexPath?.row == 0 {
            return
        } else {
            descriptionTextView.resignFirstResponder()
        }
    }
    // MARK: - Navigation Bar
    
    @IBAction func done(){
        print("DescriptionText: \(descriptionText)")
        
        let hudView = HudView.hudInView(view: navigationController!.view, animated: true)
        var location:Location
        
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext) as! Location
            location.photoID = nil
        }
        
        location.locationDescription = descriptionText
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark

        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            
            let data = image.jpegData(compressionQuality: 0.5)
  
            do {
                try data?.write(to: location.photoPath, options: .atomic)
            } catch {
                print("Error writing file: \(error)")
            }
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error: error as NSError)
            return
        }
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            self.dismiss(animated: true, completion: nil)
        })
        
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
        switch(indexPath.section, indexPath.row){
        case(0,0):
            return 88
        case(1,_):
            return imageView.isHidden ? 44 : CGFloat(imageHeight + 20)
        case(2,2):
            addressLabel.frame.size = CGSize(width:view.bounds.size.width - 115, height:10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            return addressLabel.frame.size.height + 20
        default:
            return 44
            
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
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
    
    // MARK: - image view
    func showImage(image:UIImage){
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        
        print("addPhotoLabel.isHidden \(addPhotoLabel.isHidden)")
        addPhotoLabel.isHidden = true
        
    }
    
    func listenForBackgroundNotification(){
        
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: {
                                                [weak self] _ in
                                                if let strongSelf = self {
                                                    if strongSelf.presentedViewController != nil {
                                                        print("*** closure called")
                                                        strongSelf.dismiss(animated: false, completion: nil)
                                                    }
                                                    strongSelf.descriptionTextView.resignFirstResponder()
                                                }

        })
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

extension LocationDetailViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoWithCamera(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: {
            print(#function)
        })
        
    }
    
    func choosePhotoFromLibary(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: {
            print(#function)
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func pickPhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibary()
        }
    }
    
    func showPhotoMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {_ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibaryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {_ in self.choosePhotoFromLibary()})
        alertController.addAction(chooseFromLibaryAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
