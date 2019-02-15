//
//  GSRReservationsController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/14/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class GSRReservationsController: UITableViewController {
    
    var reservations: [GSRReservation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your Bookings"
        
        tableView.delegate = self
        
        guard let sessionID = UserDefaults.standard.getSessionID() else {
            return
        }
        WhartonGSRNetworkManager.instance.getReservations(for: sessionID) { (reservations) in
            DispatchQueue.main.async {
                if let reservations = reservations {
                    self.reservations = reservations
                    self.tableView.dataSource = self
                } else {
                    // TODO: Handle failure to retrieve reservations.
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension GSRReservationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let reservation = reservations[indexPath.row]
        cell.textLabel?.text = "\(reservation.location) \(reservation.startTime) \(reservation.endTime)"
        return cell
    }
}
