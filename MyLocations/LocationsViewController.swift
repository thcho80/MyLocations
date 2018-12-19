//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by human on 2018. 12. 17..
//  Copyright © 2018년 com.humantrion. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController:UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
//    var locations = [Location]()
    
    lazy var fetchedResultsController:NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in 
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptor2]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
        
        fetchedResultsController.delegate = (self as NSFetchedResultsControllerDelegate)
        
        return fetchedResultsController
        
    }()
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // MARK = UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
        let location = fetchedResultsController.object(at: indexPath) as! Location
        
        cell.configureForLocation(location: location)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath) as! Location
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error: error as NSError)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo:NSFetchedResultsSectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performFetch()
        
        self.navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func performFetch(){
        do {
            try fetchedResultsController.performFetch()
        } catch{
            fatalCoreDataError(error: error as NSError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("segue.identifier: \(String(describing: segue.identifier))")
    
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailViewController
            
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = fetchedResultsController.object(at: indexPath) as! Location
                controller.locationToEdit = location
            }
        }
    }
}


extension LocationsViewController:NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** \(#function)")
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            print("*** NSFetchedResultsChange insert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchedResultsChange delete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("*** NSFetchedResultsChange update (object)")
            let cell = tableView.cellForRow(at: indexPath!) as! LocationCell
            let location = controller.object(at: indexPath!) as! Location
            cell.configureForLocation(location: location)
        case .move:
            print("*** NSFetchedResultsChange move (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        switch type {
        case .insert:
            print("*** NSFetchedResultsChange insert (section)")
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            print("*** NSFetchedResultsChange insert (section)")
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .update:
            print("*** NSFetchedResultsChange update (section)")
        case .move:
            print("*** NSFetchedResultsChange move (section)")

        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** \(#function)")
        tableView.endUpdates()
    }
}
