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

    fileprivate var reservations: [GSRReservation] = []
    fileprivate var barButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = nil // Don't try to load data initially since reservations will be nil
        tableView.delegate = self
        tableView.register(ReservationCell.self, forCellReuseIdentifier: ReservationCell.identifier)
        tableView.register(NoReservationsCell.self, forCellReuseIdentifier: NoReservationsCell.identifier)
        tableView.tableFooterView = UIView()

        let sessionID = UserDefaults.standard.getSessionID()
        let email = GSRUser.getUser()?.email
        if sessionID == nil && (email == nil || email!.contains("wharton")) {
            self.prepareLoginButton()
            self.tableView.dataSource = self
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchData { (success) in
            // Handle if not successful
        }
    }
}

// MARK: - UITableViewDataSource
extension GSRReservationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(reservations.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.reservations.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoReservationsCell.identifier, for: indexPath) as! NoReservationsCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ReservationCell.identifier, for: indexPath) as! ReservationCell
        cell.reservation = reservations[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = UITableViewCell.SelectionStyle.none;
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ReservationCell.cellHeight
    }
}

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

// MARK: Login Button
extension GSRReservationsController {
    func prepareLoginButton() {
        barButton = UIBarButtonItem(title: "Login", style: .done, target: self, action: #selector(handleBarButtonPressed(_:)))
        barButton.tintColor = UIColor.navigationBlue
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleBarButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Select GSR System", message: "Choose the system to login for.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Library", style: .default, handler: { (_) in
            DispatchQueue.main.async {
                self.presentLoginFlow(isWharton: false)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Wharton", style: .default, handler: { (_) in
            DispatchQueue.main.async {
                self.presentLoginFlow(isWharton: true)
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func presentLoginFlow(isWharton: Bool) {
        if isWharton {
            let wv = GSRWebviewLoginController()
            wv.completion = {
                let sessionID = UserDefaults.standard.getSessionID()
                if sessionID == nil {
                    self.showAlert(withMsg: "Uh oh!", title: "Login invalid. Please try again.", completion: nil)
                    return
                }
            }
            let nvc = UINavigationController(rootViewController: wv)
            present(nvc, animated: true, completion: nil)
        } else {
            let glc = GSRLoginController()
            let nvc = UINavigationController(rootViewController: glc)
            present(nvc, animated: true, completion: nil)
        }
    }
    
    func fetchData(_ completion: @escaping (_ success: Bool) -> Void) {
        let sessionID = UserDefaults.standard.getSessionID()
        let email = GSRUser.getUser()?.email
        if sessionID == nil && email == nil {
            completion(false)
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
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
