//  GoogleAnalyticsManager.swift
//  PennMobile
//
//  Created by Josh Doman on 4/18/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

@objc class GoogleAnalyticsManager: NSObject {
    
    static let shared = GoogleAnalyticsManager()
    
    static func prepare() {
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true
        gai?.dryRun = true //prevents GoogleAnalytics tracking (remove before production release)
        //gai?.logger.logLevel = .verbose //MUST COMMENT OUT BEFORE RELEASE
        gai?.dispatchInterval = 20
        gai?.defaultTracker = GAI.sharedInstance().tracker(withName: "PennMobile", trackingId: "UA-96870393-1")
    }
    
    @objc func trackScreen(_ name: String) {
        GAI.sharedInstance().defaultTracker?.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        if let build = builder?.build() as? [AnyHashable: Any] {
            GAI.sharedInstance().defaultTracker?.send(build)
        }
    }
    
    @objc func trackEvent(category: String, action: String, label: String, value: NSNumber) {
        GAI.sharedInstance().defaultTracker?.send(GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value).build() as! [AnyHashable : Any]!)
    }
    
    struct events {
        struct category {
            static let studyRoomBooking = "Study Room Booking"
        }
        
        struct action {
            static let attemptReservation = "Attempted reservation"
        }
    }
}
