//
//  GSRBookable.swift
//  PennMobile
//
//  Created by Josh Doman on 2/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

protocol GSRBookable: IndicatorEnabled, ShowsAlert {}

extension GSRBookable where Self: UIViewController {
    func submitBooking(for booking: GSRBooking) {
        self.showActivity()
        GSRNetworkManager.instance.makeBooking(for: booking) { result in
            DispatchQueue.main.async {
                self.hideActivity()
                var firebaseResult: FirebaseAnalyticsManager.EventResult

                switch result {
                case .success:
                    self.showAlert(withMsg: "You booked a space in \(booking.roomName). You should receive a confirmation email in the next few minutes.", title: "Success!", completion: nil)
                    firebaseResult = .success
                    guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else { return }
                    homeVC.clearCache()
                case .failure:
                    self.showAlert(withMsg: "You seem to have exceeded the booking limit for this venue.", title: "Uh oh!", completion: nil)
                    firebaseResult = .failed
                }

                FirebaseAnalyticsManager.shared.trackEvent(action: .attemptBooking, result: firebaseResult, content: booking.roomName)
            }
        }
    }
}
