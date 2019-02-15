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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let sessionID = UserDefaults.standard.getSessionID() else {
            return
        }
        WhartonGSRNetworkManager.instance.getReservations(for: sessionID) { (reservations) in
            if let reservations = reservations {
                for reservation in reservations {
                    print(reservation.location, reservation.startTime, reservation.endTime)
                }
            } else {
                print("Unable to retrieve your reservations.")
            }
        }
    }
}
