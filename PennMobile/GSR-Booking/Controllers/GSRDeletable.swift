//
//  GSRDeletable.swift
//  PennMobile
//
//  Created by Josh Doman on 3/24/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

protocol GSRDeletable: IndicatorEnabled, ShowsAlert {}

extension GSRDeletable where Self: UIViewController {
    func deleteReservation(_ reservation: GSRReservation, _ callback: @escaping (_ success: Bool) -> Void) {
        confirmDelete {
            self.showActivity()
            let sessionID = UserDefaults.standard.getSessionID()
            GSRNetworkManager.instance.deleteReservation(reservation: reservation, sessionID: sessionID) { (success, errorMsg) in
                DispatchQueue.main.async {
                    self.hideActivity()
                    if success {
                        callback(true)
                    } else if let errorMsg = errorMsg {
                        self.showAlert(withMsg: errorMsg, title: "Uh oh!", completion: nil)
                        callback(false)
                    }
                }
            }
        }
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
