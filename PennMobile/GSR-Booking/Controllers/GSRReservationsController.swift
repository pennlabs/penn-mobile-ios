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
<<<<<<< HEAD

<<<<<<< HEAD
=======
                
>>>>>>> gsr reservations cells with image
        title = "Your Bookings"

        tableView.delegate = self
        tableView.register(ReservationCell.self, forCellReuseIdentifier: ReservationCell.identifer)

        guard let sessionID = UserDefaults.standard.getSessionID() else { return }
        WhartonGSRNetworkManager.instance.getReservations(for: sessionID) { (reservations) in
            DispatchQueue.main.async {
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
        return reservations?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReservationCell.identifer, for: indexPath) as! ReservationCell
        cell.reservation = reservations[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none;
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ReservationCell.cellHeight
    }
}

// MARK: - ReservationCellDelegate
extension GSRReservationsController: ReservationCellDelegate {
    func deleteReservaton(_ reservation: GSRReservation) {
        guard let sessionID = UserDefaults.standard.getSessionID() else { return }
        showActivity()
        WhartonGSRNetworkManager.instance.deleteReservation(sessionID: sessionID, bookingID: reservation.id) { (success, errorMsg) in
            DispatchQueue.main.async {
                self.hideActivity()
                if success {
                    self.reservations = self.reservations.filter { $0.id != reservation.id }
                    self.tableView.reloadData()
                } else if let errorMsg = errorMsg {
                    self.showAlert(withMsg: errorMsg, title: "Uh oh!", completion: nil)
                }
        guard let sessionID = UserDefaults.standard.getSessionID() else {
            return
        }
=======
        guard let sessionID = UserDefaults.standard.getSessionID() else { return }
>>>>>>> reservation cell & deletion
        WhartonGSRNetworkManager.instance.getReservations(for: sessionID) { (reservations) in
            DispatchQueue.main.async {
                if let reservations = reservations {
                    self.reservations = reservations
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                } else {
                    // TODO: Handle failure to retrieve reservations.
                }
            } else {
                print("Unable to retrieve your reservations.")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ReservationCell.identifer, for: indexPath) as! ReservationCell
        cell.reservation = reservations[indexPath.row]
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ReservationCell.cellHeight
    }
}

// MARK: - ReservationCellDelegate
extension GSRReservationsController: ReservationCellDelegate {
    func deleteReservation(_ reservation: GSRReservation) {
        guard let sessionID = UserDefaults.standard.getSessionID() else { return }
        showActivity()
        WhartonGSRNetworkManager.instance.deleteReservation(sessionID: sessionID, bookingID: reservation.id) { (success, errorMsg) in
            DispatchQueue.main.async {
                self.hideActivity()
                if success {
                    self.reservations = self.reservations.filter { $0.id != reservation.id }
                    self.tableView.reloadData()
                } else if let errorMsg = errorMsg {
                    self.showAlert(withMsg: errorMsg, title: "Uh oh!", completion: nil)
                }
            }
        }
    }
}
