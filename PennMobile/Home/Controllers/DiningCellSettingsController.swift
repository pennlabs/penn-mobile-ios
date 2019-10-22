//
//  DiningCellSettingsController.swift
//  PennMobile
//
//  Created by Daniel Salib on 2/8/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import UIKit

protocol DiningCellSettingsDelegate {
    func saveSelection(for cafes: [DiningVenue])
}

class DiningCellSettingsController: UITableViewController {

    var delegate: DiningCellSettingsDelegate?

    var chosenVenueIds = Set<Int>()
    let allVenues = DiningDataStore.shared.getVenues()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DiningVenueSettingsCell")
        tableView.allowsMultipleSelection = true
        navigationItem.title = "Select Favorites"
        self.navigationController?.navigationBar.tintColor = UIColor.navigationBlue
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(handleSave))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allVenues.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiningVenueSettingsCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = allVenues[indexPath.row].name

        if chosenVenueIds.contains(allVenues[indexPath.row].id) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if chosenVenueIds.contains(indexPath.row) {
            chosenVenueIds.remove(indexPath.row)
        } else {
            chosenVenueIds.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
        FirebaseAnalyticsManager.shared.trackEvent(action: .updateDiningPreferences, result: .cancelled, content: chosenVenueIds.count)
    }

    @objc func handleSave() {
        let chosenVenues = chosenCafes.map {DiningVenue(venue: $0)}
        delegate?.saveSelection(for: chosenVenues)
        self.dismiss(animated: true, completion: nil)
        FirebaseAnalyticsManager.shared.trackEvent(action: .updateDiningPreferences, result: .success, content: chosenVenueIds.count)
    }

    func setupFromVenues(venues: [DiningVenue]) {
        chosenVenueIds = Set(venues.map { $0.id })
    }
}
