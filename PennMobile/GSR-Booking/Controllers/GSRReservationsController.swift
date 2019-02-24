//
//  GSRReservationsController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/14/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit

class GSRReservationsController: UITableViewController, ShowsAlert, IndicatorEnabled {

    var reservations: [GSRReservation]!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Your Bookings"
        
        tableView.dataSource = nil // Don't try to load data initially since reservations will be nil
        tableView.delegate = self
        tableView.register(ReservationCell.self, forCellReuseIdentifier: ReservationCell.identifier)
        tableView.register(NoReservationsCell.self, forCellReuseIdentifier: NoReservationsCell.identifier)
        tableView.tableFooterView = UIView()

        let sessionID = UserDefaults.standard.getSessionID()
        let email = GSRUser.getUser()?.email
        if sessionID == nil && email == nil {
            // TODO: Handle user that is not logged in
            return
        }
        self.showActivity()
        GSRNetworkManager.instance.getReservations(sessionID: sessionID, email: email) { (reservations) in
            DispatchQueue.main.async {
                self.hideActivity()
                if let reservations = reservations {
                    self.reservations = reservations
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
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
        return max(reservations?.count ?? 0, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.reservations?.count ?? 0 == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoReservationsCell.identifier, for: indexPath) as! NoReservationsCell
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ReservationCell.identifier, for: indexPath) as! ReservationCell
        cell.reservation = reservations[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        return cell

//        if self.rooms.count > indexPath.section {
//            let room = rooms[indexPath.section]
//            let cell = tableView.dequeueReusableCell(withIdentifier: laundryCell) as! LaundryCell
//            cell.room = room
//            cell.delegate = self
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: addLaundryCell) as! AddLaundryCell
//            cell.delegate = self
//            cell.numberOfRoomsSelected = self.rooms.count
//            return cell
//        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ReservationCell.cellHeight
    }
}

//// MARK: - UITableViewDataSource
//extension GSRReservationsController {
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return reservations?.count ?? 0
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ReservationCell.identifer, for: indexPath) as! ReservationCell
//        cell.reservation = reservations[indexPath.row]
//        cell.delegate = self
//        return cell
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return ReservationCell.cellHeight
//    }
//}

// MARK: - ReservationCellDelegate
extension GSRReservationsController: ReservationCellDelegate {
    func deleteReservation(_ reservation: GSRReservation) {
        showActivity()
        let sessionID = UserDefaults.standard.getSessionID()
        GSRNetworkManager.instance.deleteReservation(reservation: reservation, sessionID: sessionID) { (success, errorMsg) in
            DispatchQueue.main.async {
                self.hideActivity()
                if success {
                    self.reservations = self.reservations.filter { $0.bookingID != reservation.bookingID }
                    self.tableView.reloadData()
                } else if let errorMsg = errorMsg {
                    self.showAlert(withMsg: errorMsg, title: "Uh oh!", completion: nil)
                }
            }
        }
    }
}
