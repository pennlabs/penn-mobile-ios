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
                var result: FirebaseAnalyticsManager.EventResult = .failed
                if success {
                    alertView.showSuccess("Success!", subTitle: "You booked a space in \(booking.location.name). You should receive a confirmation email in the next few minutes.")
                    result = .success
//                    guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else { return }
//                    homeVC
                } else if let msg = errorMessage {
                    alertView.showError("Uh oh!", subTitle: msg)
                }
                FirebaseAnalyticsManager.shared.trackEvent(action: .attemptBooking, result: result, content: booking.location.name)
                completion(success)
            }
        }
    }
}
