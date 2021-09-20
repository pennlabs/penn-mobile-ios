//  GoogleAnalyticsManager.swift
//  PennMobile
//
//  Created by Josh Doman on 4/18/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class FirebaseAnalyticsManager: NSObject {
    
    static let shared = FirebaseAnalyticsManager()
    private override init() {}
    
    func trackScreen(_ name: String) {
        Analytics.logEvent(AnalyticsEventScreenView,
                           parameters: [AnalyticsParameterScreenName: name])
    }
    
    func trackEvent(action: EventAction, result: EventResult, content: Any) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: action.rawValue,
            AnalyticsParameterItemName: result.rawValue,
            AnalyticsParameterContentType: content
            ])
    }
    
    func trackEvent(action: String, result: String, content: Any) {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: action,
            AnalyticsParameterItemName: result,
            AnalyticsParameterContentType: content
            ])
    }
    
    enum EventAction: String {
        case viewWebsite = "HomeWebsite"
        case attemptBooking = "Booking"
        case laundryTapped = "LaundryTapped"
        case updateDiningPreferences = "UpdateDiningPref"
        case twoStep = "TwoStep"
        case twoStepRetrieval = "TwoStepRetrieval"
    }
    
    enum EventResult: String {
        case cancelled = "Cancelled"
        case success = "Success"
        case failed = "Failed"
        case enabled = "Enabled"
        case disabled = "Disabled"
        case declined = "Declined"
        case none = ""
    }
}
