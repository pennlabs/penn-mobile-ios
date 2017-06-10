//
//  GoogleAnalyticsManager.swift
//  PennMobile
//
//  Created by Josh Doman on 4/18/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

@objc class GoogleAnalyticsManager: NSObject {
    
    static let shared = GoogleAnalyticsManager()
    
    func track(_ name: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        if let build = builder?.build() as? [AnyHashable: Any] {
            tracker?.send(build)
        }
    }
    
    func trackEvent(category: String, action: String, label: String, value: NSNumber) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value).build() as! [AnyHashable : Any]!)
    }
    
    struct events {
        struct category {
            static let studyRoomBooking = "Study Room Booking"
        }
        
        struct action {
            static let attemptReservation = "Submit Booking"
        }
    }
}
