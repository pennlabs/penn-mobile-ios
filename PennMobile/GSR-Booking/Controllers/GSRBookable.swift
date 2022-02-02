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
    func submitBooking(for booking: GSRBooking) {
        self.showActivity()
        GSRNetworkManager.instance.makeBooking(for: booking) { result in
            DispatchQueue.main.async {
                self.hideActivity()
                let alertView = SCLAlertView()
                var firebaseResult: FirebaseAnalyticsManager.EventResult

                switch result {
                case .success:
                    alertView.showSuccess("Success!", subTitle: "You booked a space in \(booking.roomName). You should receive a confirmation email in the next few minutes.")
                    firebaseResult = .success
                    guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else { return }
                    homeVC.clearCache()
                case .failure:
                    alertView.showError("Uh oh!", subTitle: "You seem to have exceeded the booking limit for this venue.")
                    firebaseResult = .failed
                }

                FirebaseAnalyticsManager.shared.trackEvent(action: .attemptBooking, result: firebaseResult, content: booking.roomName)
            }
        }
    }
}
