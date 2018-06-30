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
                var action: GoogleAnalyticsManager.EventAction = .failed
                if success {
                    alertView.showSuccess("Success!", subTitle: "You booked a space in \(booking.location.name). You should receive a confirmation email in the next few minutes.")
                    action = .success
                } else if let msg = errorMessage {
                    alertView.showError("Uh oh!", subTitle: msg)
                }
                GoogleAnalyticsManager.shared.trackEvent(category: .attemptedBooking, action: action, label: booking.location.name, value: success ? 1 : -1)
                completion(success)
            }
        }
    }
}
