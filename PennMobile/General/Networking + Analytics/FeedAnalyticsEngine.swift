//
//  FeedAnalyticsEngine.swift
//  PennMobile
//
//  Created by Josh Doman on 5/9/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class FeedAnalyticsManager: NSObject, Requestable {
    
    static let shared = FeedAnalyticsManager()
    private override init() {}
    
    fileprivate let baseUrl = "https://api.pennlabs.org"
    
    fileprivate var events = [FeedAnalyticsEvent]()
    
    var dryRun: Bool = false
    
    func track(event: FeedAnalyticsEvent) {
        if dryRun { return }
        events.append(event)
    }
    
    fileprivate func sendEvents() {
        if dryRun { return }
    }
}

struct FeedAnalyticsEvent: Codable {
    let cellType: String
    let index: Int
    let duration: Float
    let id: Int?
}
