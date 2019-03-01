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

    fileprivate var reservations: [GSRReservation]!
    fileprivate var loginButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        UserDefaults.standard.set(sessionID: "dpa7trlicczhjsf1s0bragq4l7ylxjnk")
        
        tableView.dataSource = nil // Don't try to load data initially since reservations will be nil
        tableView.delegate = self
        tableView.register(ReservationCell.self, forCellReuseIdentifier: ReservationCell.identifier)
        tableView.register(NoReservationsCell.self, forCellReuseIdentifier: NoReservationsCell.identifier)
        tableView.tableFooterView = UIView()

        let sessionID = UserDefaults.standard.getSessionID()
        let email = GSRUser.getUser()?.email
        if sessionID == nil && email == nil {
            // Handle user that is not logged in
            loginButton.title = "Login"
            return
        } else {
            loginButton.title = "Logout"
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
    
    override func viewDidAppear(_ animated: Bool) {
        setupNavBar()
        refreshBarButton()
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationItem.leftBarButtonItem = nil
        navigationController?.navigationItem.rightBarButtonItem = nil
        super.viewDidDisappear(animated)
    }
    
    private func setupNavBar() {
        self.navigationController?.title = "Your Reservations"
        loginButton = UIBarButtonItem(title: "Login", style: .done, target: self, action: #selector(handleBarButtonPressed(_:)))
        loginButton.tintColor = UIColor.navigationBlue
        navigationController?.navigationItem.rightBarButtonItem = loginButton
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
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ReservationCell.identifier, for: indexPath) as! ReservationCell
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

// MARK: - Bar Button Refresh + Handler
extension GSRReservationsController {
    fileprivate func refreshBarButton() {
        self.loginButton.tintColor = .clear
        let sessionID = UserDefaults.standard.getSessionID()
        let email = GSRUser.getUser()?.email
        if sessionID == nil && email == nil {
            // Handle user that is not logged in
            loginButton.title = "Login"
            return
        } else {
            loginButton.title = "Logout"
        }
        self.loginButton.tintColor = nil
    }
    
    private func presentWebviewLoginController(_ completion: (() -> Void)? = nil) {
        let wv = GSRWebviewLoginController()
        wv.completion = completion
        let nvc = UINavigationController(rootViewController: wv)
        present(nvc, animated: true, completion: nil)
    }
    
    private func presentLoginController(with booking: GSRBooking? = nil) {
        let glc = GSRLoginController()
        glc.booking = booking
        let nvc = UINavigationController(rootViewController: glc)
        present(nvc, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleBarButtonPressed(_ sender: Any) {
        if (loginButton.title == "Login") {
            presentWebviewLoginController(nil)
        }
        else {
            let message = "Are you sure you wish to log out?"
            let alert = UIAlertController(title: "Confirm Logout",
                                          message: message,
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler:{ (UIAlertAction) in
                DispatchQueue.main.async {
                    GSRUser.clear()
                    UserDefaults.standard.clearSessionID()
                    self.refreshBarButton()
                }
            }))
            present(alert, animated: true)
        }
}
    
}
