//
//  GSRBookable.swift
//  PennMobile
//
//  Created by Josh Doman on 2/4/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol GSRBookable: IndicatorEnabled, ShowsAlert {}

extension GSRBookable where Self: UIViewController {
    func submitBooking(for booking: GSRBooking) {
        self.showActivity()
        Task {
            var firebaseResult: FirebaseAnalyticsManager.EventResult
            do {
                try await GSRNetworkManager.makeBooking(for: booking)
                guard let homeVC = ControllerModel.shared.viewController(for: .home) as? HomeViewController else { return }
                await homeVC.clearCache()
                DispatchQueue.main.async {
                    self.showAlert(withMsg: "You booked a space in \(booking.roomName). You should receive a confirmation email in the next few minutes.", title: "Success!", completion: nil)
                }
                firebaseResult = .success
                
            } catch {
                self.showAlert(withMsg: "You seem to have exceeded the booking limit for this venue.", title: "Uh oh!", completion: nil)
                firebaseResult = .failed
            }
            FirebaseAnalyticsManager.shared.trackEvent(action: .attemptBooking, result: firebaseResult, content: booking.roomName)
            
        }
    }
}
