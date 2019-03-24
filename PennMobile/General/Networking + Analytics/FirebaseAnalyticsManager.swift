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
    
    @objc func trackScreen(_ name: String) {
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
        case viewHomeNewsArticle = "HomeNews"
        case attemptBooking = "Booking"
        case laundryTapped = "LaundryTapped"
        case updateDiningPreferences = "UpdateDiningPref"
    }
    
    enum EventResult: String {
        case cancelled = "Cancelled"
        case success = "Success"
        case failed = "Failed"
        case none = ""
    }
}
