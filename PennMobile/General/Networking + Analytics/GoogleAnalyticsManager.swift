//  GoogleAnalyticsManager.swift
//  PennMobile
//
//  Created by Josh Doman on 4/18/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

class GoogleAnalyticsManager: NSObject {
    
    static let shared = GoogleAnalyticsManager()
    
    var dryRun = false // Default unless changed in app delegate
    
    static func prepare() {
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true
        gai?.dryRun = shared.dryRun //prevents GoogleAnalytics tracking (remove before production release)
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
    
    func trackEvent(category: EventCategory, action: EventAction, label: String, value: NSNumber) {
        GAI.sharedInstance().defaultTracker?.send(GAIDictionaryBuilder.createEvent(withCategory: category.rawValue, action: action.rawValue, label: label, value: value).build() as! [AnyHashable : Any]!)
    }
    
    enum EventCategory: String {
        case attemptedBooking = "Attempted booking"
        case onboarding = "Onboarding"
    }
    
    enum EventAction: String {
        case savedSelection = "Saved selection"
        case success = "Success"
        case failed = "Failed"
    }
}
