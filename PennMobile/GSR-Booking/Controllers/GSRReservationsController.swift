//
//  GSRReservationsController.swift
//  PennMobile
//
//  Created by Josh Doman on 2/14/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class GSRReservationsController: GenericTableViewController, ShowsAlert, IndicatorEnabled {

    fileprivate var reservations: [GSRReservation] = []
    fileprivate var barButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "GSRReservation"
        tableView.dataSource = nil // Don't try to load data initially since reservations will be nil
        tableView.delegate = self
        tableView.register(ReservationCell.self, forCellReuseIdentifier: ReservationCell.identifier)
        tableView.register(NoReservationsCell.self, forCellReuseIdentifier: NoReservationsCell.identifier)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()

        self.title = "Your Bookings"
        self.navigationController?.navigationItem.backBarButtonItem?.title = "Back"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    func fetchData() {
        if self.reservations.isEmpty {
            self.showActivity()
        }
        GSRNetworkManager.instance.getReservations { result in
            DispatchQueue.main.async {
                self.hideActivity()

                if let reservations = try? result.get() {
                    self.reservations = reservations
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                } else {
                    self.present(toast: .apiError)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension GSRReservationsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(reservations.count, 1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.reservations.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoReservationsCell.identifier, for: indexPath) as! NoReservationsCell
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ReservationCell.identifier, for: indexPath) as! ReservationCell
        cell.contentView.isUserInteractionEnabled = false
        cell.reservation = reservations[indexPath.row]
        cell.delegate = self
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ReservationCell.cellHeight
    }
}

// MARK: - ReservationCellDelegate
extension GSRReservationsController: ReservationCellDelegate {
    func deleteReservation(_ reservation: GSRReservation) {
        confirmDelete {
            GSRNetworkManager.instance.deleteReservation(bookingId: reservation.bookingId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.reservations = self.reservations.filter { $0.bookingId != reservation.bookingId }
                        self.tableView.reloadData()
                    case .failure(let error):
                        self.showAlert(withMsg: error.rawValue, title: "Uh oh!", completion: nil)
                    }
                }
            }
        }
    }
    
    // <-- ADD THIS:
    func shareReservation(_ reservation: GSRReservation) {
            // 1) Gather the user's first name
        let userName = Account.getAccount()?.firstName ?? "Guest"

            // 2) Create a share model
        let shareModel = GSRShareModel(userName: userName, reservation: reservation)

            // 3) Build link: gsr://share?data=<base64>
        guard let url = shareModel.encodedURL() else { return }

            // 4) Show share sheet
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }

    func confirmDelete(_ callback: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Are you sure?", message: "Please confirm that you wish to delete this booking.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (_) in
            DispatchQueue.main.async {
                callback()
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: Login Button
// extension GSRReservationsController {
//    func prepareLoginButton() {
//        barButton = UIBarButtonItem(title: "Login", style: .done, target: self, action: #selector(handleBarButtonPressed(_:)))
//        barButton.tintColor = UIColor.navigation
//        navigationItem.rightBarButtonItem = barButton
//    }
//
//    @objc func handleBarButtonPressed(_ sender: Any) {
//        let alertController = UIAlertController(title: "Select GSR System", message: "Choose the system to login for.", preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "Library", style: .default, handler: { (_) in
//            DispatchQueue.main.async {
//                self.presentLoginFlow(isWharton: false)
//            }
//        }))
//        alertController.addAction(UIAlertAction(title: "Wharton", style: .default, handler: { (_) in
//            DispatchQueue.main.async {
//                self.presentLoginFlow(isWharton: true)
//            }
//        }))
//        present(alertController, animated: true, completion: nil)
//    }
//
//    func presentLoginFlow(isWharton: Bool) {
//        if isWharton {
//            let wv = GSRWebviewLoginController()
//            wv.completion = {
//                let sessionID = GSRUser.getSessionID()
//                if sessionID == nil {
//                    self.showAlert(withMsg: "Uh oh!", title: "Login invalid. Please try again.", completion: nil)
//                    return
//                }
//            }
//            let nvc = UINavigationController(rootViewController: wv)
//            present(nvc, animated: true, completion: nil)
//        } else {
//            let glc = GSRLoginController()
//            let nvc = UINavigationController(rootViewController: glc)
//            present(nvc, animated: true, completion: nil)
//        }
//    }
// }
