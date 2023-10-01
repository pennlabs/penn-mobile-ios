//
//  PennEventsViewController.swift
//  PennMobile
//
//  Created by Samantha Su on 10/1/21.
//  Copyright © 2021 PennLabs. All rights reserved.
//

import Foundation
import SwiftSoup
import PennMobileShared

class PennEventsTableViewController: GenericTableViewController, IndicatorEnabled {

    var events: [PennEvents] = []
    let dateKey = "dateKey"

    override func viewDidAppear(_ animated: Bool) {
        // attempt to fetch date from UserDefaults
        if let date = UserDefaults.standard.object(forKey: dateKey) as? Date {
            if date.isToday {
                events = Storage.retrieve(PennEvents.directory, from: .documents, as: [PennEvents].self)
                tableView.reloadData()
            } else {
                fetchEvents()
                UserDefaults.standard.set(Date(), forKey: dateKey)
            }
        } else {
            fetchEvents()
            UserDefaults.standard.set(Date(), forKey: dateKey)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PennEventsTableViewCell.self, forCellReuseIdentifier: "PennEventsTableViewCell")
        tableView.separatorStyle = .none
        self.title = "Events"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
}

// MARK: - Networking to retrieve events
extension PennEventsTableViewController {
    fileprivate func fetchEvents() {
        EventsAPI.instance.fetchEvents { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.events = events
                    Storage.store(events, to: .documents, as: PennEvents.directory)
                case .failure(.serverError):
                    self.navigationVC?.addStatusBar(text: .apiError)
                default:
                    self.navigationVC?.addStatusBar(text: .noInternet)
                }
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
}

// MARK: - TableView Datasource
extension PennEventsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PennEventsTableViewCell", for: indexPath) as! PennEventsTableViewCell
        cell.pennEvent = events[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PennEventsTableViewCell else {return}
        cell.isExpanded = !cell.isExpanded
        cell.bodyLabel.numberOfLines = cell.isExpanded ? 3: 0
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
