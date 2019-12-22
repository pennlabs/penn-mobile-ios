//
//  FeedAnalyticsEngine.swift
//  PennMobile
//
//  Created by Josh Doman on 5/9/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

class FeedAnalyticsManager: NSObject, Requestable {
    var dryRun: Bool {
        #if DEBUG
           return true
        #else
            return false
        #endif
    }
    
    fileprivate let eventSeparationMinimum = 30 // 30 minutes must pass for cell to be tracked twice
    fileprivate let defaultBatchSize = 5 // Send all events if at least 8 cells have been tracked
    fileprivate let maxWaitTime: TimeInterval = 15 // Send all events if it's been more than 15 seconds since last sent
    
    static let shared = FeedAnalyticsManager()
    private override init() {
        super.init()
        self.resetTimer()
    }
    
    fileprivate let analyticsUrl = "http://api.pennlabs.org/feed/analytics"
    
    fileprivate var mostRecentEvent = Dictionary<FeedAnalyticsEvent, Date>() // Keeps track of the last time a cell was tracked
    fileprivate var eventsToSend = Set<FeedAnalyticsEvent>()
    
    fileprivate var batchTimer: Timer!
    
    func track(cellType: String, index: Int, id: String?, batchSize: Int? = nil) {
        if dryRun { return }
        
        let event = FeedAnalyticsEvent(cellType: cellType, id: id, index: index, isInteraction: false, timestamp: Date())
        
        var eventAdded = false
        if let lastSent = mostRecentEvent[event], !eventsToSend.contains(event) {
            if lastSent.minutesFrom(date: event.timestamp) >= eventSeparationMinimum {
                eventsToSend.insert(event)
                eventAdded = true
            }
        } else {
            eventsToSend.insert(event)
            eventAdded = true
        }
        
        var maxBatchSize = batchSize ?? defaultBatchSize
        if eventAdded, let batchSize = batchSize {
            // Count number of non-interactions that have been sent in the last 30 minutes
            let count = mostRecentEvent.keys.filter { (thisEvent) -> Bool in
                if thisEvent.isInteraction {
                    return false
                } else if let lastSent = mostRecentEvent[thisEvent] {
                    if lastSent.minutesFrom(date: Date()) >= eventSeparationMinimum {
                        return false
                    }
                }
                return true
            }.count
            // Limit batch size to the number of cells that have not yet been seen
            maxBatchSize = batchSize - count
        }
        
        if eventsToSend.count >= maxBatchSize {
            sendEvents()
        } else if !eventsToSend.isEmpty && !batchTimer.isValid {
            // Reset the timer if there are events to send and the timer is not valid (not currently running)
            resetTimer()
        }
    }
    
    @objc func sendEvents() {
        if dryRun || eventsToSend.isEmpty { return }
        // Send the events
        saveEventsOnDB(eventsToSend)
        
        // Set date for last time this cell was tracked, remove events waiting to be sent, update last sent date
        for event in eventsToSend {
            mostRecentEvent[event] = event.timestamp
        }
        eventsToSend.removeAll()
        batchTimer.invalidate()
    }
    
    func trackInteraction(cellType: String, index: Int, id: String?) {
        if dryRun { return }
        let event = FeedAnalyticsEvent(cellType: cellType, id: id, index: index, isInteraction: true, timestamp: Date())
        
        if let lastSent = mostRecentEvent[event], !eventsToSend.contains(event) {
            if lastSent.minutesFrom(date: event.timestamp) >= eventSeparationMinimum {
                eventsToSend.insert(event)
            }
        } else {
            eventsToSend.insert(event)
        }
        
        // Send all the events immediately upon an interaction
        sendEvents()
    }
    
    func resetTimer() {
        batchTimer = Timer.scheduledTimer(timeInterval: maxWaitTime, target: self, selector: #selector(sendEvents), userInfo: nil, repeats: false)
    }
    
    func save() {
        if !eventsToSend.isEmpty {
            UserDefaults.standard.saveEventLogs(events: eventsToSend)
        }
    }
    
    func removeSavedEvents() {
        UserDefaults.standard.clearEventLogs()
    }
    
    func sendSavedEvents() {
        if let events = UserDefaults.standard.getUnsentEventLogs() {
            self.eventsToSend = events
            sendEvents()
            UserDefaults.standard.clearEventLogs()
        }
    }
}

struct FeedAnalyticsEvent: Codable, Hashable {
    let cellType: String
    let id: String?
    let index: Int
    let isInteraction: Bool
    let timestamp: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(cellType)
        hasher.combine(id)
        hasher.combine(isInteraction)
    }
    
    static func == (lhs: FeedAnalyticsEvent, rhs: FeedAnalyticsEvent) -> Bool {
        return lhs.cellType == rhs.cellType && lhs.id == rhs.id && lhs.isInteraction == rhs.isInteraction
    }
}

// MARK: - Networking
extension FeedAnalyticsManager {
    fileprivate func saveEventsOnDB(_ events: Set<FeedAnalyticsEvent>) {
        let sortedEvents = events.sorted { (e1, e2) -> Bool in
            return e1.timestamp < e2.timestamp
        }
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        jsonEncoder.dateEncodingStrategy = .formatted(formatter)
        do {
            var request = getAnalyticsRequest(url: analyticsUrl) as URLRequest
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try jsonEncoder.encode(sortedEvents)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
        catch {
        }
    }
}
