//
//  GSROverhallController.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 2/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import UIKit

class GSROverhallController: GenericTableViewController {
    
    internal let roomCell = "roomCell"
    
    fileprivate var currentRooms = [GSRRoom]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Study Room Booking"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: roomCell)

        updateRooms(for: 1086)
    }
}

// MARK: - Update Rooms
extension GSROverhallController {
    func updateRooms(for id: Int) {
        GSROverhaulManager.instance.getAvailability(for: id) { (rooms) in
            DispatchQueue.main.async {
                if let rooms = rooms {
                    self.currentRooms = rooms
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension GSROverhallController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return currentRooms.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentRooms[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: roomCell, for: indexPath)
        cell.textLabel?.text = String(currentRooms[indexPath.section].timeSlots.count)
        return cell
    }
}
