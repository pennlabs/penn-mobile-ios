//
//  GSRBookable.swift
//  PennMobile
//
//  Created by Josh Doman on 2/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import SCLAlertView

protocol GSRBookable: IndicatorEnabled {}

extension GSRBookable where Self: UIViewController {
    func submitBooking(for booking: GSRBooking, _ completion: @escaping (_ success: Bool) -> Void) {
        self.showActivity()
        GSRNetworkManager.instance.makeBooking(for: booking) { (success, errorMessage) in
            DispatchQueue.main.async {
                self.hideActivity()
                let alertView = SCLAlertView()
                if success {
                    alertView.showSuccess("Success!", subTitle: "You should receive a confirmation email in the next few minutes.")
                } else if let msg = errorMessage {
                    alertView.showError("Uh oh!", subTitle: msg)
                }
                completion(success)
            }
        }
    }
}
