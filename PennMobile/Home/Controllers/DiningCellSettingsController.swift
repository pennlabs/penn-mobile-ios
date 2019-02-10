//
//  DiningCellSettingsController.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/8/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

protocol DiningCellSettingsDelegate {
    func saveSelection(for cafes: [DiningVenueName])
}

class DiningCellSettingsController: UITableViewController {
    
    var delegate: DiningCellSettingsDelegate?
    
    var chosenCafes = [DiningVenueName]()
    
    let cafes = DiningVenue.diningNames + DiningVenue.retailNames

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsCell")
        tableView.allowsMultipleSelection = true
        navigationItem.title = "Select Favorites"
        self.navigationController?.navigationBar.tintColor = UIColor.navigationBlue
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for cafe in chosenCafes {
            if let index = cafes.index(of: cafe) {
                tableView.selectRow(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafes.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = cafes[indexPath.row].rawValue
        
        if chosenCafes.contains(cafes[indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cafe = cafes[indexPath.row]
        
        if !chosenCafes.contains(cafe) {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
            chosenCafes.append(cafe)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cafe = cafes[indexPath.row]
        
        if chosenCafes.contains(cafe) {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
            
            if let index = chosenCafes.index(of: cafe) {
                chosenCafes.remove(at: index)
            }
        }
    }
    
    func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleSave() {
        delegate?.saveSelection(for: chosenCafes)
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupFromVenues(venues: [DiningVenue]) {
        chosenCafes = venues.map {$0.name}
    }
}
