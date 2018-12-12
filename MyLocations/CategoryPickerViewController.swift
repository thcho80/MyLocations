//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by human on 2018. 12. 12..
//  Copyright © 2018년 com.humantrion. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    
    var selectedCatagoryName = ""
    
    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "BookStore",
        "Club",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"
    ]
    
    var selectedIndexPath = NSIndexPath()

    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UITableViewCell
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCatagoryName {
            cell.accessoryType = .checkmark
            selectedIndexPath = indexPath as NSIndexPath
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            
            if let oldCell = tableView.cellForRow(at: selectedIndexPath as IndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath as NSIndexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCatagoryName = categories[indexPath.row]
            }
        }
    }
}
